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
powertime=0;
powersound=0;

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
eyes=false;
BEGIN

load_fpg("pac2600.fpg");
sounds[0]=load_wav("sounds/CHOMP.wav",0);
sounds[1]=load_wav("sounds/BOOP.wav",0);
sounds[2]=load_wav("sounds/START.wav",0);
sounds[3]=load_wav("sounds/DEATH.wav",0);
sounds[4]=load_wav("sounds/beeew.wav",1);
sounds[5]=load_wav("sounds/BUP_BWOOP.wav",0);
sounds[6]=load_wav("sounds/WHISTLE.wav",0);

put_screen(file,100);
set_fps(60,0);
LOOP
    playing=false;
    maze();
    frame;

    WHILE(get_id(type wafer) || get_id(type powerpill))
        FRAME;
        gactive++;

        IF(gactive==4)
            gactive=0;
        END

        IF(powertime>0)
            powertime--;

            IF(powertime==0)
                stop_sound(powersound);
            END
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
eatsound=0;
g=0;

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
    g=collision(type ghost);
    IF(g)
        if(g.eyes==false)
        IF(powertime<1)
            playing=false;
            sound(sounds[3],255,255);

            FROM graph = 4 to 10;
                FRAME(1600);
            END

            RETURN;
        ELSE
            g.eyes=true;
            playing=false;
            eatsound=sound(sounds[5],255,255);
            WHILE(is_playing_sound(eatsound))
            IF(anim++>10)
                anim=0;
                animf++;

                IF(animf==4)
                    animf=0;
                END

                graph=frames[animf];

            END
            FRAME;
            END
            sound(sounds[6],255,255);
            playing=true;

        END
        END

    END


    FRAME;

END

END



PROCESS ghost(x,y,gid);

private
homex=0;
homey=0;

ograph=0;
try1=0;
sw=0;
BEGIN
    homex=x;
    homey=y;

    dx=1;
    graph=30;
   // eyes=1;
    write_int(0,0,gid*10,0,&homex);
    write_int(0,30,gid*10,0,&homey);
    write_int(0,60,gid*10,0,&dx);
    write_int(0,90,gid*10,0,&dy);
    write_int(0,120,gid*10,0,&x);
    write_int(0,150,gid*10,0,&y);
    write_int(0,180,gid*10,0,&try1);


    LOOP

        IF(playing)
            p = map_get_pixel(file,101,x,y-1);

            IF(p==54)
                ox=dx;
                oy=dy;
                dx=0;
                dy=0;
            END

            if(eyes)
                try1=4;
            else
                try1=0;
            end

            WHILE(dx==0 && dy==0)
               // if(eyes && try1>0)
               //     sw=try1-1;
             //   else
                    sw=rand(0,3);
             //   end
                IF(eyes && try1>0)
                    switch(try1)

                    case 1:
                    IF(homex>x)
                        dx=1;
                    END
                    end

                    case 2:
                    if(homex<x && dx==0)
                        dx=-1;
                    END
                    end

                    case 3:
                    if(homey<y && dx==0)
                        dy=-1;
                    END
                    end

                    case 4:

                    if(homey>y && dx==0 && dy==0)
                        dy=1;
                    END

                    end

                    end

                ELSE
                SWITCH(sw)

                    CASE 0:
                        if(homex>x && try1>0)
                            dx=1;
                        else
                            dx=1;
                        end
                    END

                    CASE 1:
                        if(homex<x && try1>0)
                            dx=-1;
                        else
                            dx=-1;
                        end
                    END

                    CASE 2:
                        if(homey>y && try1>0 )
                       // debug;
                            dy=1;
                        else
                            dy=1;
                        end
                    END


                    CASE 3:
                        if(homey<y && try1>0)
                            dy=-1;
                        else
                            dy=-1;
                        end
                    END
                END
                END

                if(dx==0 && dy==0)
                   debug;
                ELSE

                IF(map_get_pixel(file,101,x+dx,y-1+dy)==0)
                    dx=0;
                    dy=0;
                END

                IF(dx==-ox && dy==-oy)
                    dx=0;
                    dy=0;
                END
                end
                try1--;
            END

            ox=x;
            oy=y;
            if(eyes==1 && homex==x && homey==y)
            if(powertime<1)
                eyes=false;
                dx=0;
                dy=0;

            end

            else

            x=x+dx;
            y=y+dy;
            end

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

        ograph=graph;

        IF(eyes==true)
            graph=34;
        END

        size=100*(gid==gactive);

        IF(powertime>0)
            graph+=10;
        END

        FRAME;

        graph=ograph;



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

stop_sound(powersound);

sound(sounds[1],255,255);
score+=10;

powersound=sound(sounds[4],255,255);
powertime=400;


END



PROCESS bonus(x,y)

BEGIN

graph=22;

LOOP

    FRAME;

END

END
