#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef uint8_t bool;
#define true 1
#define false 0

// ------------------ Structures ------------------

#pragma pack(push, 1) // prevent padding

typedef struct
{
    uint8_t BootJumpInstruction[3];
    uint8_t OemIdentifier[8];
    uint16_t BytesPerSector;
    uint8_t SectorsPerCluster;
    uint16_t ReservedSectors;
    uint8_t FatCount;
    uint16_t DirEntryCount;
    uint16_t TotalSectors;
    uint8_t MediaDescriptorType;
    uint16_t SectorsPerFat;
    uint16_t SectorsPerTrack;
    uint16_t Heads;
    uint32_t HiddenSectors;
    uint32_t LargeSectorCount;

    // Extended Boot Record
    uint8_t DriveNumber;
    uint8_t _Reserved;
    uint8_t Signature;
    uint32_t VolumeId;
    uint8_t VolumeLabel[11];
    uint8_t SystemId[8];
} BootSector;

typedef struct
{
    uint8_t Name[11];
    uint8_t Attributes;
    uint8_t _Reserved;
    uint8_t CreatedTimeTenths;
    uint16_t CreatedTime;
    uint16_t CreatedDate;
    uint16_t AccessedDate;
    uint16_t FirstClusterHigh;
    uint16_t ModifiedTime;
    uint16_t ModifiedDate;
    uint16_t FirstClusterLow;
    uint32_t Size;
} DirectoryEntry;

#pragma pack(pop)

// ------------------ Globals ------------------

BootSector g_BootSector;
uint8_t *g_Fat = NULL;
DirectoryEntry *g_RootDirectory = NULL;
uint32_t g_RootDirectoryEnd;

// ------------------ FileSystem Read Functions ------------------

bool readBootSector(FILE *disk)
{
    return fread(&g_BootSector, sizeof(BootSector), 1, disk) == 1;
}

bool readSectors(FILE *disk, uint32_t lba, uint32_t count, void *buffer)
{
    return fseek(disk, lba * g_BootSector.BytesPerSector, SEEK_SET) == 0 &&
           fread(buffer, g_BootSector.BytesPerSector, count, disk) == count;
}

bool readFat(FILE *disk)
{
    size_t fatSize = g_BootSector.SectorsPerFat * g_BootSector.BytesPerSector;
    g_Fat = malloc(fatSize);
    return g_Fat && readSectors(disk, g_BootSector.ReservedSectors, g_BootSector.SectorsPerFat, g_Fat);
}

bool readRootDirectory(FILE *disk)
{
    uint32_t rootStartLBA = g_BootSector.ReservedSectors + g_BootSector.SectorsPerFat * g_BootSector.FatCount;
    uint32_t dirSizeBytes = g_BootSector.DirEntryCount * sizeof(DirectoryEntry);
    uint32_t dirSectors = (dirSizeBytes + g_BootSector.BytesPerSector - 1) / g_BootSector.BytesPerSector;

    g_RootDirectoryEnd = rootStartLBA + dirSectors;
    g_RootDirectory = malloc(dirSectors * g_BootSector.BytesPerSector);
    return g_RootDirectory && readSectors(disk, rootStartLBA, dirSectors, g_RootDirectory);
}

DirectoryEntry *findFile(const char *name)
{
    for (uint32_t i = 0; i < g_BootSector.DirEntryCount; i++)
    {
        if (memcmp(name, g_RootDirectory[i].Name, 11) == 0)
            return &g_RootDirectory[i];
    }
    return NULL;
}

bool readFile(DirectoryEntry *fileEntry, FILE *disk, uint8_t *outputBuffer)
{
    uint16_t cluster = fileEntry->FirstClusterLow;
    bool ok = true;

    while (ok && cluster < 0xFF8)
    {
        uint32_t lba = g_RootDirectoryEnd + (cluster - 2) * g_BootSector.SectorsPerCluster;
        ok = readSectors(disk, lba, g_BootSector.SectorsPerCluster, outputBuffer);
        outputBuffer += g_BootSector.SectorsPerCluster * g_BootSector.BytesPerSector;

        // FAT12 cluster lookup
        uint32_t fatIndex = (cluster * 3) / 2;
        if (cluster % 2 == 0)
            cluster = (*(uint16_t *)(g_Fat + fatIndex)) & 0x0FFF;
        else
            cluster = (*(uint16_t *)(g_Fat + fatIndex)) >> 4;
    }

    return ok;
}

// ------------------ Main Program ------------------

int main(int argc, char **argv)
{
    if (argc != 3)
    {
        fprintf(stderr, "Usage: %s <disk.img> <FILENAME.EXT>\n", argv[0]);
        return 1;
    }

    FILE *disk = fopen(argv[1], "rb");
    if (!disk)
    {
        perror("Failed to open disk image");
        return 1;
    }

    if (!readBootSector(disk))
    {
        fprintf(stderr, "Error reading boot sector.\n");
        fclose(disk);
        return 1;
    }

    if (!readFat(disk))
    {
        fprintf(stderr, "Error reading FAT table.\n");
        fclose(disk);
        return 1;
    }

    if (!readRootDirectory(disk))
    {
        fprintf(stderr, "Error reading root directory.\n");
        free(g_Fat);
        fclose(disk);
        return 1;
    }

    DirectoryEntry *entry = findFile(argv[2]);
    if (!entry)
    {
        fprintf(stderr, "File '%s' not found in root directory.\n", argv[2]);
        free(g_Fat);
        free(g_RootDirectory);
        fclose(disk);
        return 1;
    }

    uint8_t *buffer = malloc(entry->Size + g_BootSector.BytesPerSector);
    if (!buffer)
    {
        fprintf(stderr, "Memory allocation failed.\n");
        free(g_Fat);
        free(g_RootDirectory);
        fclose(disk);
        return 1;
    }

    if (!readFile(entry, disk, buffer))
    {
        fprintf(stderr, "Error reading file content.\n");
        free(g_Fat);
        free(g_RootDirectory);
        free(buffer);
        fclose(disk);
        return 1;
    }

    // Output the file content
    for (uint32_t i = 0; i < entry->Size; i++)
    {
        if (isprint(buffer[i]))
            putchar(buffer[i]);
        else
            printf("<%02X>", buffer[i]);
    }
    printf("\n");

    // Cleanup
    free(buffer);
    free(g_Fat);
    free(g_RootDirectory);
    fclose(disk);
    return 0;
}
