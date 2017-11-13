rm(list=ls())
WORK_SPACE="E:/Zhenling_论文数据计算/2017_wheat/20171113/"
setwd(WORK_SPACE)


SOURCE_PATH="clustalw_out/"
RESULT_PATH="result/"


for( aln_file in dir(path= SOURCE_PATH,pattern ="*.aln") )
{

con <- file( paste0(SOURCE_PATH,aln_file), "r")

###con <- file("GF_8847.aln", "r")
lastFlag=""
CURRENT_LINE=""
A_LINE=""
B_LINE=""
D_LINE=""
A_COL=""
B_COL=""
D_COL=""
while( TRUE ){
	line=readLines(con,n=1)
	##3print(line)
	if (  regexpr(">chr[0-9][A,B,D]",line)[1] >=1  ||  length(line) == 0 ){
		if (lastFlag == "A" ) {A_LINE = CURRENT_LINE ; A_COL= lastCOL}
		if (lastFlag == "B" ) {B_LINE = CURRENT_LINE ; B_COL= lastCOL}
		if (lastFlag == "D" ) {D_LINE = CURRENT_LINE ; D_COL= lastCOL}

		if ( length(line) == 0  )  break 
		##取下一组
		lastFlag =substr(line,6,6) 
		lastCOL =substr(line,2,nchar(line))
		CURRENT_LINE =""
		next ##非开始行数据


	}
	CURRENT_LINE=paste0(CURRENT_LINE ,line )
	##print(CURRENT_LINE)
}
### close readed file 
close(con)

## ready for compare and write file
if (nchar(A_LINE) != nchar(B_LINE) || nchar(A_LINE) != nchar(D_LINE) || nchar(B_LINE) != nchar(D_LINE)) 
{

	print(paste0("A_LINE Length:",nchar(A_LINE)))
	print(paste0("B_LINE Length:",nchar(B_LINE)))
	print(paste0("D_LINE Length:",nchar(D_LINE)))
	print(paste0(aln_file,": A_LINE,B_LINE,D_LINE is length is not equal"))
	break
}

## get the start of absolute position 
start_postion_A = as.integer(substr(A_COL,regexpr("_",A_COL)[1]+1,regexpr("-",A_COL)[1]-1) )
start_postion_B = as.integer(substr(B_COL,regexpr("_",B_COL)[1]+1,regexpr("-",B_COL)[1]-1) )
start_postion_D = as.integer(substr(D_COL,regexpr("_",D_COL)[1]+1,regexpr("-",D_COL)[1]-1) )

## compared position Initialization
postion_A = 0 
postion_B = 0 
postion_D = 0 


RESULT_FILE= paste0(RESULT_PATH,"merged_triplets_10172_",aln_file,"_vcf.txt")
TITLE= "bed_gene\tTraces\tchromo\tabsolute_position\tcompared_position\taln_position\tbase"
write(TITLE,file=RESULT_FILE,append= FALSE)

for (i in 1: nchar(A_LINE)){
	C_A= substr(A_LINE,i,i)
	C_B= substr(B_LINE,i,i)
	C_D= substr(D_LINE,i,i)


	## "-" 不记入绝对位置
	if(C_A != "-") { postion_A = postion_A + 1 }
	if(C_B != "-") { postion_B = postion_B + 1 }
	if(C_D != "-") { postion_D = postion_D + 1 }
	
	## 只输出A,B,D值是AGTC,并且A,B,D不一样的数据
	if ( C_A != "-" && C_B != "-" && C_D != "-" && 
	     C_A != "N" && C_B != "N" && C_D != "N" &&
		 C_A != C_B && C_B != C_D                  ){
	out_line= paste0(A_COL,"\t",substr(A_COL,1,5),"\t",start_postion_A + postion_A ,"\t",postion_A,"\t",i,"\t",C_A,"\n",
					 B_COL,"\t",substr(B_COL,1,5),"\t",start_postion_B + postion_B ,"\t",postion_B,"\t",i,"\t",C_B,"\n",
					 D_COL,"\t",substr(D_COL,1,5),"\t",start_postion_D + postion_D ,"\t",postion_D,"\t",i,"\t",C_D)
	write(out_line,file=RESULT_FILE,append= TRUE)
	}
}

}

