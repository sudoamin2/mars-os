[BITS 32]
PMEntry:
      mov ax, 0x10
      mov ds, ax
      mov es, ax
      mov ss, ax
      mov esp, 0x7c00

      mov byte[0xb8000], 'p'
      mov byte[0xb8001], 0xa

      ; enable the A20 line
      ; https://wiki.osdev.org/A20_Line
      in al, 0x92
      or al, 2
      out 0x92, al

      jmp PBEnd

PBEnd:
      hlt
      jmp PBEnd
