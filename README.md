## Description
Script written in AT&T assembly responding to the Intel IA32 processor running Windows 7.

## Approach

The designed run-length algorithm focuses on a simplified Portable Bitmap (PBM) binary image format.

**Example of compression:**

*.pbm* file to be compressed:

```sh
0x5031000F00020000000000000000000000000000000000000000000000000000000000FF

```

Resulting *.rle* file:

```sh
0x524C4549000F00020006001D000001FF
```

The decompression procedure works inversely.
