; kernel.paging.initSegment
global ret
ret:
  mov rsp, rbp
  pop rbp
  ret

; kernel.paging.initPaging
global setcr3
setcr3:
  mov cr3, rdi
  ret
