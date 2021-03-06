//===- LC3bInstrInfo.td - Target Description for LC3b Target -*- tablegen -*-=//
//
//                                                The LLVM Compiler Infrastructure
//
// This file is a project of EE382V, Code Generation and Optimization course,
// at the University of Texas at Austin
//
//===----------------------------------------------------------------------===//

include "LC3bInstrFormats.td"

def simm5 : Operand<i16>{
	let DecoderMethod= "DecodeSimm5";
}
def simm6 : Operand<i16> {
	let DecoderMethod = "DecodeSimm6";
}

def imm4 : Operand<i16> {
   let DecoderMethod = "Decodeimm4";
}

def simm9 : Operand<i16> {
    let DecoderMethod = "DecodeSimm9";
}

def immSExt5 : PatLeaf<(imm), [{ return isInt<5>(N->getSExtValue()); }]>;
def immSExt6 : PatLeaf<(imm), [{ return isInt<6>(N->getSExtValue()); }]>;
def immExt4  : PatLeaf<(imm), [{ return isInt<4>(N->getZExtValue()); }]>;  
def immSExt9 : PatLeaf<(imm), [{ return isInt<9>(N->getSExtValue()); }]>;


def jmptarget    : Operand<OtherVT> {
	let EncoderMethod = "getJumpTargetOpValue";
	let OperandType = "OPERAND_PCREL";
	let DecoderMethod = "DecodeJumpRelativeTarget";
}

// Address operand (PatFrag)
def mem : Operand<iPTR> {
    let PrintMethod     = "printMemOperand";
    let MIOperandInfo   = (ops LC3bRegs, simm6); //FIXME 
    let EncoderMethod   = "getMemEncoding";
}

def mem_lea : Operand<iPTR> {
  	let PrintMethod = "printMemOperandEA";
    let MIOperandInfo = (ops LC3bRegs, simm9);
	let EncoderMethod = "getMemEncoding";
}



//class EffectiveAddress<string instr_asm, RegisterClass RC, Operand Mem> 
//: FMem<0x09, (outs RC:$ra), (ins Mem:$addr), instr_asm, [(set RC:$ra, addr:$addr)], IIAlu>;


// LC3b Address Mode! SDNode frameindex could possibily be a match
// since load and store instructions from stack used it.



def addr : ComplexPattern< iPTR, 2, "SelectAddr", [frameindex], [SDNPWantParent] >;
//FIXME: a function with the name SelectAddr should be created by tablegen....not created causing error in LC3bGenDAGISel.inc:


//===----------------------------------------------------------------------===//
// Pattern fragment for load/store
//===----------------------------------------------------------------------===//
class AlignedLoad<PatFrag Node> : 
PatFrag <(ops node:$ptr), (Node node:$ptr), 
	[{  
		LoadSDNode *LD = cast<LoadSDNode>(N); 
		return LD->getMemoryVT().getSizeInBits()/8 <= LD->getAlignment();
	}]  
>;  

class AlignedStore<PatFrag Node> 
: PatFrag <(ops node:$val, node:$ptr), (Node node:$val, node:$ptr), 
	[{  
		StoreSDNode *SD = cast<StoreSDNode>(N);
		return SD->getMemoryVT().getSizeInBits()/8 <= SD->getAlignment();
	}]  
>;  

// Load/Store PatFrags.
def load_a  : AlignedLoad<load>;
def store_a : AlignedStore<store>;


def ADDrr : rrForm<0x1, (outs LC3bRegs:$dst), (ins LC3bRegs:$src1, LC3bRegs:$src2),
                   "add $dst, $src1, $src2", [(set LC3bRegs:$dst, (add LC3bRegs:$src1, LC3bRegs:$src2))], IIAlu>;

/*def ADDri :*/

def ADDri : riForm <0x1,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, simm5:$immsext5),
                   "add $dst, $src1, $immsext5",[(set LC3bRegs:$dst, (add LC3bRegs:$src1, immSExt5:$immsext5))], IIAlu>;

/*def ANDrr :*/

def ANDrr : rrForm<0x5, (outs LC3bRegs:$dst), (ins LC3bRegs:$src1, LC3bRegs:$src2),
                   "and $dst, $src1, $src2", [(set LC3bRegs:$dst, (and LC3bRegs:$src1, LC3bRegs:$src2))], IIAlu>;

/*def ANDri :*/

def ANDri : riForm <0x5,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, simm5:$immsext5),
                   "and $dst, $src1, $immsext5",[(set LC3bRegs:$dst, (and LC3bRegs:$src1, immSExt5:$immsext5))], IIAlu>;

/*def XORrr :*/

def XORrr : rrForm<0x9, (outs LC3bRegs:$dst), (ins LC3bRegs:$src1, LC3bRegs:$src2),
                   "xor $dst, $src1, $src2", [(set LC3bRegs:$dst, (xor LC3bRegs:$src1, LC3bRegs:$src2))], IIAlu>;

/*def XORri :*/

def XORri : riForm <0x9,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, simm5:$immsext5),
                   "xor $dst, $src1, $immsext5",[(set LC3bRegs:$dst, (xor LC3bRegs:$src1, immSExt5:$immsext5))], IIAlu>;


/*def LEA :*/

def lea : leaForm <0xe,(outs LC3bRegs:$dst), (ins simm9:$immsext9),
                   	"lea $dst, $immsext9",[(set LC3bRegs:$dst, (add 0, immSExt9:$immsext9))], IILea>;


/*def BR :*/

/*def JMP :*/

/*def JSR :*/

/*def JSRR :*/
def JSRR     : jsrrForm<0x4,(outs), (ins jmptarget:$addr),
			"jsrr $addr", [(br bb:$addr)], IIBranch>;

/*def LDB :*/
def LDBri : memForm < 0x2,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, mem:$addr),
           "ldb $dst, $src1 ,$addr",[(set LC3bRegs:$dst, (sextloadi8 (add LC3bRegs:$src1, addr:$addr)))], IILoad>;

/*def LDW :*/
def LDWri : memForm < 0x6,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, mem:$addr),
           "ldw $dst, $addr",[(set LC3bRegs:$dst, (load_a  (add LC3bRegs:$src1, addr:$addr)))], IILoad>;

/*def STB :*/ 
def STBri : memForm < 0x3,(outs), (ins LC3bRegs:$src1, LC3bRegs:$dst, mem:$addr),
                   "stb $dst, $src1, $addr",[(truncstorei8 LC3bRegs:$dst, (add LC3bRegs:$src1, addr:$addr))], IIStore>;

/*def STW :*/ 
def STWri : memForm < 0x7,(outs), (ins LC3bRegs:$src1, LC3bRegs:$dst, mem:$addr),
                   "stw $dst,$src1, $addr",[(store_a LC3bRegs:$dst, (add LC3bRegs:$src1, addr:$addr))], IIStore >;


/*def RTI :*/

/*def LSHF :*/
def LSHF : shfForm <0xd,0x00,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, imm4:$immext4), 
					"lshf $dst, $src1, $immext4", [(set LC3bRegs:$dst, (shl LC3bRegs:$src1, immExt4:$immext4))], IIShf>;

/*def RSHFL :*/
def RSHFL : shfForm <0xd,0x01,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, imm4:$immext4), 
					"rshfl $dst, $src1, $immext4", [(set LC3bRegs:$dst, (srl LC3bRegs:$src1, immExt4:$immext4))], IIShf>;

/*def RSHFA :*/
def RSHFA : shfForm <0xd,0x02,(outs LC3bRegs:$dst), (ins LC3bRegs:$src1, imm4:$immext4), 
					"rshfa $dst, $src1, $immext4", [(set LC3bRegs:$dst, (sra LC3bRegs:$src1, immExt4:$immext4))], IIShf>;
					
/*def TRAP :*/


