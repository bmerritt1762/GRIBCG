predictSGRNA <-
function(seq.vec,outfile='output'){
  data('coef.fin')
  cat('Make sure PAM (NGG) sequence is at position 31,32,33 of each sequence','\n')
  dummy.seq <- 'GACTTTGGGTACGGCTTGTTCTTACAATACCGGTAACTGC'
  seq.vec <- as.factor(c(as.character(dummy.seq),as.character(seq.vec)))
  seq1 <- lapply(as.character(seq.vec),function(x){strsplit(x,split='')[[1]]})
  names(seq1) <- seq.vec
  L <- lapply(seq1,function(x){length(x)})
  seq1 <- seq1[unlist(L)==40]
  cat('Number of input sequence: ',length(seq.vec)-1,'\n')
  cat('Number of input sequence with L=40: ',length(which(unlist(L)==40))-1,'\n')
  if(length(seq1)<=1){
    cat('ERROR: Sequence must of be length 40bp with PAM (NGG) at position 31,32,33!','\n')
    return(0)
  }else{
  seq2.mat <- t(sapply(seq1,function(x){paste(x[c(1:30,34:39)],x[c(2:31,35:40)],sep='')}))
  template.mat <- matrix(rep(paste(rep(c('A','T','C','G'),each=4),rep(c('A','T','C','G'),4),sep=''),36),ncol=36)

  cur.mat <- rbind(template.mat,seq2.mat)
  mod.mat <- NULL
  for(i in 1:dim(template.mat)[2]){
    mod.mat <- cbind(mod.mat,model.matrix(~c(as.character(cur.mat[,i])))[,-1])
  }
  mod.mat.fin <- cbind(rep(1,dim(mod.mat)[1]),mod.mat)
  prob <- (exp(mod.mat.fin%*%coef.fin)/(1+exp(mod.mat.fin%*%coef.fin)))[-c(1:17)]
  class <- rep('NotEfficient',length(prob))
  class[prob >= 0.5] <- 'Efficient'
  res <- cbind(data.frame(names(seq1)[-1]),class,prob)
  colnames(res) <- c('Sequence','Predicted Class (Cutoff 0.5)','P(Efficient)')
  outfileName <- paste(outfile,'.csv',sep='')
  write.csv(res,outfileName,quote=FALSE,row.names=FALSE)
  cat('DONE! Results saved in file ',outfileName,'\n')
}
}
