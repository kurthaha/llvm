//===- LC3bCallingConv.td - Calling Conventions for LC3b ---*- tablegen -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// This describes the calling conventions for LC3b architecture.
//===----------------------------------------------------------------------===//

/// CCIfSubtarget - Match if the current subtarget has a feature F.

class CCIfSubtarget<string F, CCAction A>: CCIf<!strconcat("State.getTarget().getSubtarget<LC3bSubtarget>().", F), A>; 

def CSR_O32 : CalleeSavedRegs<(add LR, FP,(sequence "S%u", 2, 0))>;
