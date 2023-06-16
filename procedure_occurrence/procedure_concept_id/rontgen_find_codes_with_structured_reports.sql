select rvc.CODE code, count(*) n
from `iconic-guard-317109.wise.W_STRUCTURED_DATA` wsd
inner join `iconic-guard-317109.wise.W_EXAM` we
on wsd.WSD_EXAM_ID = we.WEXAM_ID
inner join `iconic-guard-317109.hix.RONTGEN_VERRCODE` rvc
on we.WEXAM_CODE = rvc.CODE or we.WEXAM_CODE = rvc.ZOEKCODE or we.WEXAM_CODE = rvc.AFSPRCODE
group by code
order by code asc