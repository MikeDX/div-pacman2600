/***

PAC-MAC 2600

Remake using DIV Games studio

Started: 29/03/2015 20:26

***/
program pac2600;

global sounds[10];


BEGIN

load_fpg("pac2600.fpg");
sounds[0]=load_wav("sounds/CHOMP.wav",0);

put_screen(file,100);
set_fps(60,0);
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

get_point(file,101,5,&px, &py);
pac(px,py);



END

PROCESS wafer(x,y)

BEGIN

graph=20;


repeat

frame;

until (collision(type pac));

sound(sounds[0],255,255);


END


PROCESS pac(x,y)

private
p;
ox;
oy;
nx=0;
ny=0;
dx=0;
dy=0;
ody=0;
odx=0;

BEGIN
y++;
x--;
graph=1;
write_int(0,0,0,0,&p);
write_int(0,10,0,0,&dx);
write_int(0,20,0,0,&dy);


loop

ox=x;
oy=y;

if(key(_left))
x-=2;
nx=-2;
ny=0;
end

if(key(_right))
x+=2;
nx=2;
ny=0;

end

if(key(_up))
y-=2;
ny=-2;
nx=0;
end

if(key(_down))
y+=2;
ny=2;
nx=0;
end

p=map_get_pixel(file,101,x,y-1);

if((x!=ox || y!=oy) && p==22)
    dx=nx;
    dy=ny;
else
    x=ox;
    y=oy;
    x=x+dx;
    y=y+dy;
    p=map_get_pixel(file,101,x,y-1);

    if(p!=22)
        x=ox;
        y=oy;
        dx=0;
        dy=0;
    end
end

frame;

end



END

PROCESS ghost(x,y);

BEGIN

END

PROCESS powerpill(x,y)

BEGIN
graph=21;

repeat

size=100*((timer/20)&1);

frame;

until(collision(type pac));


END

PROCESS bonus(x,y)

BEGIN

graph=22;

loop

frame;

end

END
