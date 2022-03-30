%include "bootloader/longmode.asm"

[BITS 32]

; in protected mode and long mode we can not use the BIOS functions
protected_mode:
      cli ; disable interrupts, interrupts will be enabled in kernel
      
      mov ax, 0x10 ; 16 in hex. third entry in the GDT (data segment)
      mov ds, ax
      mov es, ax
      mov ss, ax
      mov esp, 0x7c00 ; the stack pointer in protected mode

      ; enable the A20 line
      ; https://wiki.osdev.org/A20_Line
      in al, 0x92
      or al, 2
      out 0x92, al

      ; ENABLE LONG MODE
      ; paging is required in long mode
      
      ; START PAGING
      ; https://wiki.osdev.org/Setting_Up_Paging

      ; The address (0x80000 - 0x90000) is used for BIOS data
      ; We use memory area from 0x70000 to 0x80000 instead
      ; https://wiki.osdev.org/Memory_Map_(x86)

      ; finds a free memory area and intialize the paging structure   
      cld
      mov edi, 0x70000
      xor eax, eax
      mov ecx, 0x10000/4
      rep stosd ; stosd instruction copies the data item from EAX (for doublewords) to the destination string, pointed to by ES:DI in memory.

      mov dword[0x70000], 0x71007 ; U=0 W=1 P=1  here we have 7 instead of 3
      ; the page directory pointer table
      ; base address of the physical page is set to 0
      ; the attribute here is set to 3
      ; bit 7 indicate this is 1G physical page translation
      mov dword[0x71000], 10000111b 

      mov eax, (0xffff800000000000>>39)
      and eax, 0x1ff
      mov dword[0x70000+eax*8], 0x72003
      mov dword[0x72000], 10000011b

      ; END PAGING

      lgdt [GDT64_PTR]

      ; bit 5 in cr4 register is called physical address extension
      ; set it to 1
      mov eax, cr4
      or eax, (1<<5)
      mov cr4, eax

      ; copy the address of the page structure
      mov eax, 0x70000
      mov cr3, eax

      mov ecx, 0xc0000080
      rdmsr
      or eax, (1<<8)
      wrmsr

      mov eax, cr0
      or eax, (1<<31)
      mov cr0, eax

      ; 8 -> since each entry is 8 bytes and the code segment selector is the second entry
      ; then the offset of long mode
      jmp 8:long_mode


GDT32:
      ; the first entry
      dq 0 ; each entry is 8 bytes, dq to allocate 8 bytes space
; the code segment entry
CODE32:
      dw 0xffff
      dw 0
      db 0
      db 0x9a
      db 0xcf
      db 0
; the data segment entry
DATA32:
      dw 0xffff
      dw 0
      db 0
      db 0x92
      db 0xcf
      db 0

GDT32_LEN: equ $ - GDT32

GDT32_PTR:
      dw GDT32_LEN - 1
      dd GDT32
