//==- LC3bFrameLowering.h - Define frame lower for LC3b ----------*- C++ -*-==//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//

#ifndef LC3b_FRAMEINFO_H
#define LC3b_FRAMEINFO_H

#include "LC3b.h"
#include "llvm/Target/TargetFrameLowering.h"

namespace llvm {
		class LC3bSubtarget;
		class LC3bFrameLowering : public TargetFrameLowering {
				protected:
				const LC3bSubtarget &STI;
				public:
				explicit LC3bFrameLowering(const LC3bSubtarget &sti) : TargetFrameLowering(StackGrowsDown, 8, 0),STI(sti) {
				}
				/// emitProlog/emitEpilog - These methods insert prolog and epilog code into
				/// the function.

				void emitPrologue(MachineFunction &MF) const;
				void emitEpilogue(MachineFunction &MF, MachineBasicBlock &MBB) const;
				bool hasFP(const MachineFunction &MF) const;
		};
} // End llvm namespace
#endif
