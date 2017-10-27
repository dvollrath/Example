drop polsres
drop polsres_t1

reg dlnrexppch dgini_t1 if dpercurb_t1~=., cluster(id)
predict polsres, residual
gen polsres_t1=polsres[_n-1]
replace polsres_t1=. if id~=id[_n-1]
reg polsres polsres_t1
test polsres_t1==-.5


drop polsres
drop polsres_t1

reg dlnrexppch dgini_t1 dlnrincpc_t1  if dpercurb_t1~=., cluster(id)
predict polsres, residual
gen polsres_t1=polsres[_n-1]
replace polsres_t1=. if id~=id[_n-1]
reg polsres polsres_t1
test polsres_t1==-.5



drop polsres
drop polsres_t1

reg dlnrexppch dgini_t1 dlnrincpc_t1 dpercurb_t1  if dpercurb_t1~=., cluster(id)
predict polsres, residual
gen polsres_t1=polsres[_n-1]
replace polsres_t1=. if id~=id[_n-1]
reg polsres polsres_t1
test polsres_t1==-.5



drop polsres
drop polsres_t1


reg dlnrexppch dgini_t1 dlnrincpc_t1 dpercurb_t1 dpercblack_t1  if dpercurb_t1~=., cluster(id)
predict polsres, residual
gen polsres_t1=polsres[_n-1]
replace polsres_t1=. if id~=id[_n-1]
reg polsres polsres_t1
test polsres_t1==-.5



drop polsres
drop polsres_t1

reg dlnrexppch dgini_t1 dlnrincpc_t1 dpercurb_t1 dpercblack_t1 dlnrexppch_t1  if dpercurb_t1~=., cluster(id)
predict polsres, residual
gen polsres_t1=polsres[_n-1]
replace polsres_t1=. if id~=id[_n-1]
reg polsres polsres_t1
test polsres_t1==-.5


