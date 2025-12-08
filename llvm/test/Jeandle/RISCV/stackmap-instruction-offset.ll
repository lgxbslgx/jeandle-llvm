; RUN: llc --filetype=obj -mtriple=riscv64-unknown-linux-gnu < %s | llvm-readobj --stackmap - | FileCheck %s

declare zeroext i1 @return_i1()
declare zeroext i32 @return_i32()
declare ptr @return_i32ptr()

define i32 @test_i32_return() gc "statepoint-example" {
; CHECK: Record ID: 0, instruction offset: 20
; CHECK-NOT: Record ID: 0, instruction offset: 0
; CHECK: Record ID: 2, instruction offset: 44
; CHECK-NOT: Record ID: 2, instruction offset: 0
; CHECK: Record ID: 1, instruction offset: 56
; CHECK-NOT: Record ID: 1, instruction offset: 0
entry:
  %safepoint_token = tail call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 0, i32 0, ptr elementtype(i32 ()) @return_i32, i32 0, i32 0, i32 0, i32 0)
  %call1 = call zeroext i32 @llvm.experimental.gc.result.i32(token %safepoint_token)
  %1 = add i32 %call1, 123
  %2 = icmp eq i32 %1, 0
  br i1 %2, label %block1, label %block2

block1:
  %safepoint_token1 = tail call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 1, i32 0, ptr elementtype(ptr ()) @return_i32ptr, i32 0, i32 0, i32 0, i32 0)
  %call2 = call ptr @llvm.experimental.gc.result.p0(token %safepoint_token1)
  br label %return.block

block2:
  %safepoint_token2 = tail call token (i64, i32, ptr, i32, i32, ...) @llvm.experimental.gc.statepoint.p0(i64 2, i32 0, ptr elementtype(i1 ()) @return_i1, i32 0, i32 0, i32 0, i32 0)
  %call3 = call zeroext i1 @llvm.experimental.gc.result.i1(token %safepoint_token2)
  br label %return.block

return.block:
  ret i32 %call1
}
