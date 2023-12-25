

10 poke 59393,0:rem allow writes to ROM area

100 a=9*4096
110 n$="edit40g"
120 gosub 10000

200 a=828
210 n$="loadrom.bin"
220 gosub 10000

300 sys828

10000 rem load a file to memory
10010 print "load " n$ " at " a
10110 open 1,8,0,n$
10210 get#1,a$
10215 if a$="" then v=0:goto 10230
10220 v=asc(a$)
10230 poke a,v
10240 a=a+1
10250 if st <> 64 then 10210
10260 close 1
10270 print "end at " a
10290 return


