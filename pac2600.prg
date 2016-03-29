/***

PAC-MAC 2600

Remake using DIV Games studio

Started: 29/03/2015 20:26



***/
program pac2600;

BEGIN

load_fpg("pac2600.fpg");

put_screen(file,100);

maze();
LOOP

FRAME;

END

end

PROCESS maze()

private
px;
py;


begin

signal(type ghost, s_kill);
signal(type wafer, s_kill);
signal(type powerpill, s_kill);
signal(type pac, s_kill);
signal(type bonus, s_kill);

from x = 9 to 134;
get_point(file,101,x,&px, &py);
wafer(px,py);
end

from x = 1 to 4;
get_point(file,101,x,&px,&py);
powerpill(px,py);
end


END

PROCESS wafer(x,y)

BEGIN

graph=20;


loop

frame;

end


END


PROCESS pac()

BEGIN



END

PROCESS ghost(x,y);

BEGIN

END

PROCESS powerpill(x,y)

BEGIN
graph=21;

loop

size=100*(timer&1);

frame;

end


END

PROCESS bonus(x,y)

BEGIN

graph=22;

loop

frame;

end

END
