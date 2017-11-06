rm(list=ls())
WORK_SPACE="E:/Zhenling_论文数据计算/2017_wheat/20171106/"
setwd(WORK_SPACE)
library(gsubfn)
library(sqldf)
library(pheatmap)




### A_DATA =read.table("source/A.txt",head=F,fill=T,sep = "\t" )
### B_DATA =read.table("source/B.txt",head=F,fill=T,sep = "\t" )
### D_DATA =read.table("source/D.txt",head=F,fill=T,sep = "\t" )
ABD_DATA =read.table("source/ABD.txt",head=F,fill=T,sep = "\t" )


###for (  i in 1:3 ) {
###
###  if (i == 1 ) {FILE_DATA = A_DATA ; TYPE = "A" }
###  if (i == 2 ) {FILE_DATA = B_DATA ; TYPE = "B" }
###  if (i == 3 ) {FILE_DATA = D_DATA ; TYPE = "D" }
  
  FILE_DATA = ABD_DATA ;TYPE = "ABD"
  i = 1
  
  ### 取v2 ~ vmax 
   sqlstr=""
   for (j in 1:ncol(FILE_DATA) -1  ){
     if (j < 2 ) next ;
 	sqlstr = paste0( sqlstr,"select v1,v", j  ," from FILE_DATA union \n" )
	}
	
    ### 补上 vmax 
	sqlstr = paste0("select v1,v2 from ( \n",sqlstr,  "select v1,v", j+1," from FILE_DATA   \n" 
	
	,") a \nwhere v2 is not  null  \nand ltrim(v2) <>'' ")
  
 write.table(sqlstr, file =paste0("result/sqlstr",i,".txt"),  append = FALSE, quote = F,sep = "\t",row.names = F,col.names = TRUE, fileEncoding = "UTF-8" )

 ### 如果生成的sqlstr 太大，SQLite执行不了，有可能需要人工分拆后执行。
 ### 本例就是分拆成 result/sqlstr_2.txt 中的代码手工执行。
 DATA_DIFF = sqldf(sqlstr)
 


###  A_DATA_DIFF=sqldf("
###  select v1,v2 from (
###  select v1,v2  from A_DATA union 
###  select v1,v3  from A_DATA union
###  select v1,v4  from A_DATA union
###  select v1,v5  from A_DATA union
###  select v1,v6  from A_DATA union
###  select v1,v7  from A_DATA union
###  select v1,v8  from A_DATA union
###  select v1,v9  from A_DATA union
###  select v1,v10 from A_DATA union
###  select v1,v11 from A_DATA union
###  select v1,v12 from A_DATA union
###  select v1,v13 from A_DATA union
###  select v1,v14 from A_DATA union
###  select v1,v15 from A_DATA union
###  select v1,v16 from A_DATA  
###  ) a
###  where v2 is not  null
###  and ltrim(v2) <>'' 
###  ")


DATA_CNT=sqldf("
select 
v1, count(*) cnt
from DATA_DIFF 
group by v1 
")


DATA_A = sqldf("select * from DATA_DIFF where substr(v2,1,4) = 'subA' ")
DATA_B = sqldf("select * from DATA_DIFF where substr(v2,1,4) = 'subB' ")
DATA_D = sqldf("select * from DATA_DIFF where substr(v2,1,4) = 'subD' ")

nrow(DATA_A)
nrow(DATA_B)
nrow(DATA_D)
nrow(DATA_DIFF)


##### 统计DATA_DIFF一行中 subA,subB,subD只出现一次的行记录：V1
DATA_A1 =sqldf("select v1  from DATA_A group by v1 having count(*)  = 1  ")
DATA_B1 =sqldf("select v1  from DATA_B group by v1 having count(*)  = 1  ")
DATA_D1 =sqldf("select v1  from DATA_D group by v1 having count(*)  = 1  ")

nrow(DATA_A1)
nrow(DATA_B1)
nrow(DATA_D1)


### 以下部分内容做了一个验证，可以不执行： nrow(DATA_DIFF) 等于 DATA_ABDg1 加 nrow(DATA_A1) + nrow(DATA_B1) + nrow(DATA_D1)   
nrow(DATA_A1) + nrow(DATA_B1) + nrow(DATA_D1) 

DATA_Ag1 =sqldf(" select count(*) as cnt  from DATA_A group by v1 having count(*)  > 1     ")
DATA_Bg1 =sqldf("select  count(*) as cnt  from DATA_B group by v1 having count(*)  > 1  ")
DATA_Dg1 =sqldf("select  count(*) as cnt  from DATA_D group by v1 having count(*)  > 1  ")
 
DATA_ABDg1=sqldf("select sum(cnt) from (select cnt from DATA_Ag1  union all 
							  select cnt from DATA_Bg1  union all 
							  select cnt from DATA_Dg1   )")

### 以上部分内容做了一个验证，可以不执行
							  
### DATA_DIFF一行中 subA,subB,subD只出现一次的记录
DATA_A1B1D1=sqldf ("
select 
A.V1, ad.v2 as A_TraesCS, bd.v2 as B_TraesCS,dd.v2 as D_TraesCS
from DATA_A1 a, DATA_B1 b, DATA_D1 d, DATA_A ad, DATA_B bd, DATA_D dd
where a.v1 = b.v1 
and a.v1 = d.v1 
and a.v1 = ad.v1
and a.v1 = bd.v1
and a.v1 = dd.v1
"
)

### DATA_DIFF一行中 subA,subB 只出现一次,subD不考虑的记录
DATA_A1B1Dx=sqldf ("
select 
A.V1, ad.v2 as A_TraesCS, bd.v2 as B_TraesCS 
from DATA_A1 a, DATA_B1 b ,  DATA_A ad, DATA_B bd 
where a.v1 = b.v1 
and a.v1 = ad.v1
and a.v1 = bd.v1
"
)

nrow(DATA_A1B1D1)
nrow(DATA_A1B1Dx)



write.table( DATA_A1B1D1, file =paste0("result/",TYPE,"_DATA_A1B1D1.txt"),  append = FALSE, quote = F,sep = "\t",row.names = F,col.names = TRUE, fileEncoding = "UTF-8",na = "" )
write.table( DATA_A1B1Dx, file =paste0("result/",TYPE,"_DATA_A1B1Dx.txt"),  append = FALSE, quote = F,sep = "\t",row.names = F,col.names = TRUE, fileEncoding = "UTF-8",na = "" )



