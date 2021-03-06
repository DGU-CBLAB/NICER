############### get input ###############
args=(commandArgs(TRUE))
print(length(args))
if(length(args)!=8){
        print("Usage: R CMD BATCH --args -snp=X.txt -pheno=Y.txt -out=./ -- generateInputMS.R\n
                        snp is sample by snp matrix/vector\n
                        pheno is sample by phenotypes matrix\n")
        stop ()
}
for( i in c(1:8)){
        str = unlist(strsplit(args[i],"="))[1]
        if(str=="-snp")    		 snp = unlist(strsplit(args[i],"="))[2]
        else if(str=="-pheno")  	 pheno = unlist(strsplit(args[i],"="))[2]
        else if(str=="-out")   	 	 out = unlist(strsplit(args[i],"="))[2]
	else if(str=="-Mvalue") 	 Mvalue = unlist(strsplit(args[i],"="))[2]
	else if(str=="-MvalueThreshold") MvalueThreshold = unlist(strsplit(args[i],"="))[2]
	else if(str=="-Pdefault")        Pdefault = unlist(strsplit(args[i],"="))[2]
	else if(str=="-minGeneNumber")   minGeneNumber = as.double(unlist(strsplit(args[i],"="))[2])
	else if(str=="-NICE")  		 NICE = unlist(strsplit(args[i],"="))[2]
        else{
		print(str);
                print("Usage: R CMD BATCH --args -snp=X.txt -pheno=Y.txt -out=./ -- generateInputMS.R\n\t
                        snp is sample by snp matrix/vector\n\t
                        pheno is sample by phenotypes matrix\n")
                stop ()
        }
}
print(snp)
print(pheno)
print(out)
print(MvalueThreshold)
print(Mvalue)
print(Pdefault)
print(minGeneNumber)
print(NICE)
normMe <- function(exprs){
  return((exprs - matrix(rowMeans(exprs, na.rm=TRUE),nrow(exprs),ncol(exprs))) / matrix(apply(exprs,1,sd,na.rm=TRUE),nrow(exprs),ncol(exprs)));
}
####### generate Yi, Ki ##########
unlink(paste(out,"/NICE_temp",sep=""), recursive=TRUE)
dir.create(paste(out,"/NICE_temp",sep=""))
X = as.matrix(read.table(snp))
Y = as.matrix(read.table(pheno))
P = as.matrix(read.table(Pdefault))
snpNum = dim(X)[2]
geneNum = dim(Y)[2]
indiNum = dim(X)[1]
if (snpNum==1) {M = matrix(as.matrix(read.table(Mvalue, skip=1))[,17:(16+geneNum*2)],snpNum,geneNum*2)}
if (snpNum!=1) {M = as.matrix(read.table(Mvalue, skip=1))[,(17+geneNum):(16+geneNum*2)]}
print(dim(M))
print(snpNum)
print(geneNum)
write.table(t(Y),paste(pheno,"_t",sep=""),row.names=FALSE, col.names=FALSE, quote=FALSE)
for (i in c(1:snpNum)){                                         # for each snp, make Y_i with non significant genes using M value thresholding for the SNP
        nonSigGenes = which( M[i,] < MvalueThreshold )     # Select transbands which have base(small) baseFrac of pvalue #

        if((length(nonSigGenes) >= minGeneNumber) && length(nonSigGenes)>=10){
                print(i)
		Yi = t(Y[ ,nonSigGenes])
		Xi = t(X[ ,i])
		Ki = cov(normMe(Yi))
                write.table(t(X[ ,i]), paste(out,"/NICE_temp/X_",i,".txt",sep=""), row.names=F, col.names=F)
	 	write.table(Ki, paste(out,"/NICE_temp/K_",i,".txt",sep=""), row.names=F, col.names=F)
		destfile = paste(NICE,"/NICE_temp/P_",i,".txt",sep="")
		system(paste(NICE,"/emma ", geneNum," 1 ",indiNum," ", pheno,"_t " ,out,"/NICE_temp/X_",i,".txt ",out,"/NICE_temp/K_",i,".txt ", out,"/NICE_temp/P_",i,".txt",sep=""))
		P[i,]=t(read.table(paste(out,"/NICE_temp/P_",i,".txt",sep="")))
        }
}
unlink(paste(out,"/NICE_temp",sep=""), recursive=TRUE)
file.remove(paste(pheno,"_t",sep=""))
write.table(P, paste(out,"/NICE.txt",sep=""),row.names=FALSE, col.names=FALSE,quote=FALSE)
