  .code16
  .global start

start:
  # basic registers
  cli
  xorw %ax, %ax
  movw %ax, %ds
  movw %ax, %es
  movw %ax, %ss
  movw $start, %sp
  sti
  cld

  # drive
  movb %dl, drive

  # video
  movb $0x00, %ah
  movb $0x03, %al
  int $0x10

  mov $0x0e, %ah
  mov $0x61, %al
  int $0x10

halt:
  hlt
  jmp halt

drive:
  .byte 0
