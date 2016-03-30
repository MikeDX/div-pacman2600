/***

PAC-MAC 2600

Remake using DIV Games studio

Started: 29/03/2015 20:26

***/
program pac2600;

global sounds[10];
player=0;
start=0;
playing=false;
score=0;
gactive=0;

local
p=0;
ox=0;
oy=0;
nx=0;
ny=0;
dx=0;
dy=0;
ody=0;
odx=0;
anim=0;
animf=0;

BEGIN

load_fpg("pac2600.fpg");
sounds[0]=load_wav("sounds/CHOMP.wav",0);
sounds[1]=load_wav("sounds/BOOP.wav",0);
sounds[2]=load_wav("sounds/START.wav",0);
sounds[3]=load_wav("sounds/DEATH.wav",0);

put_screen(file,100);
set_fps(60,0);

LOOP
    playing=false;
    maze();
    frame;

    WHILE(get_id(type wafer) || get_id(type powerpill))
        FRAME;
        gactive++;
        if(gactive==4)
            gactive=0;
    END

END

signal(type maze, s_kill_tree);

END

END



PROCESS maze()

PRIVATE
px;
py;


BEGIN

signal(type ghost, s_kill);
signal(type wafer, s_kill);
signal(type powerpill, s_kill);
signal(type pac, s_kill);
signal(type bonus, s_kill);

// setup wafers
FROM x = 9 to 134;
    get_point(file,101,x,&px, &py);
    wafer(px,py);
END

// setup powerpills
FROM x = 1 to 4;
    get_point(file,101,x,&px,&py);
    powerpill(px,py);
end

LOOP

    // position pacman
    get_point(file,101,5,&px, &py);
    player=pac(px,py);

    // position ghosts
    get_point(file,101,7,&px, &py);

    FROM x = 1 to 4;
        ghost(px,py,x-1);
    END


    WHILE(get_id(type pac))
        FRAME;
    END

    signal(type ghost, s_kill);
    signal(type pac, s_kill);

END


END



PROCESS pac(x,y)

PRIVATE
frames[]=1,2,3,2;

BEGIN
y++;
x--;
graph=frames[0];

FRAME(6000);

start = sound(sounds[2],255,255);

LOOP

    IF(playing==true || !is_playing_sound(start))
        playing=true;

        ox=x;
        oy=y;

        IF(key(_left))
            x-=2;
            nx=-2;
            ny=0;
        END

        IF(key(_right))
            x+=2;
            nx=2;
            ny=0;
        END

        IF(key(_up))
            y-=2;
            ny=-2;
            nx=0;
        END

        IF(key(_down))
            y+=2;
            ny=2;
            nx=0;
        END

        p=map_get_pixel(file,101,x,y-1);

        IF((x!=ox || y!=oy) && p!=0)
            dx=nx;
            dy=ny;
        ELSE
            x=ox;
            y=oy;
            x=x+dx;
            y=y+dy;
            p=map_get_pixel(file,101,x,y-1);

            IF(p==0 && p!=39)
                x=ox;
                y=oy;
                dx=0;
                dy=0;
            END
        END

    END

    IF(anim++>10)
        anim=0;
        animf++;

        IF(animf==4)
            animf=0;
        END

        graph=frames[animf];

    END

    IF(collision(type ghost))
        playing=false;
        sound(sounds[3],255,255);

        FROM graph = 4 to 10;
            FRAME(1600);
        END

        return;

    END


    FRAME;

END

END



PROCESS ghost(x,y,gid);

BEGIN
    dx=1;
    graph=30;

    LOOP

    IF(playing)
        p = map_get_pixel(file,101,x,y-1);

        IF(p==54)
            ox=dx;
            oy=dy;
            dx=0;
            dy=0;
        END

        WHILE(dx==0 && dy==0)

            SWITCH(rand(0,4))
                CASE 0:
                    dx=1;
                END

                CASE 1:
                    dx=-1;
                END

                CASE 2:
                    dy=1;
                END

                CASE 3:
                    dy=-1;
                END
            END

            IF(map_get_pixel(file,101,x+dx,y-1+dy)!=22)
                dx=0;
                dy=0;
            END

            IF(dx==-ox && dy==-oy)
                dx=0;
                dy=0;
            END

        END

        ox=x;
        oy=y;

        x=x+dx;
        y=y+dy;

    END

    IF(y<-20)
        y+=200;
    END

    IF(y>200)
        y-=200;
    END

    IF(anim++>10)
        anim=0;
        graph++;

        IF(graph==34)
            graph=30;
        END
    END

    size=100*(gid==gactive);

    FRAME;

END

END



PROCESS wafer(x,y)

BEGIN

    graph=20;

    REPEAT

        FRAME;

    UNTIL (player.y-1==y && abs(player.x-(x+4))<5)

    sound(sounds[0],255,255);

    score++;

END



PROCESS powerpill(x,y)

BEGIN
graph=21;

REPEAT

    size=100*((timer/20)&1);

    FRAME;

UNTIL(abs(x-player.x)<2 && abs(y-player.y)<2)

sound(sounds[1],255,255);
score+=10;


END



PROCESS bonus(x,y)

BEGIN

graph=22;

LOOP

    FRAME;

END

END
