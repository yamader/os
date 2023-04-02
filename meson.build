project('yamados')

kernel = subproject('kernel')
loader = subproject('loader')

################################################################
##  dists
################################################################

ESP := ${WORK_DIR}/iso/esp.img

${TARGET}:
  [ ! -f ${TARGET} ] || mv ${TARGET} ${TARGET}.bak
  rm -rf ${WORK_DIR}/iso && mkdir -p ${WORK_DIR}/iso

  dd if=/dev/zero of=${ESP} bs=1M count=128
  mkfs.fat -n "YAMADOS_ESP" ${ESP}
  mmd -i ${ESP} ::EFI ::EFI/BOOT
  mcopy -i ${ESP} ${LOADER_PATH} ::EFI/BOOT/BOOTX64.EFI
  mcopy -i ${ESP} ${KERNEL_PATH} ::kernel.elf

  ${MKISOFS} -V "YAMADOS" \
    -iso-level 3 -full-iso9660-filenames \
    -eltorito-alt-boot -e esp.img -no-emul-boot \
    -o ${TARGET} ${WORK_DIR}/iso


mkisofs = find_program('mkisofs')
xorriso -as mkisofs


esp = custom_target('esp',
  command: [])

iso = custom_target('iso',
  command: [])

################################################################
##  run targets
################################################################

OVMF_CODE       ?= /usr/share/edk2-ovmf/OVMF_CODE.fd

run_target('run',
  command: [find_program('qemu-system-x86_64'), -bios ${OVMF_CODE} -cdrom ${TARGET}])
