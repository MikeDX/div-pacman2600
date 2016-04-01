/***

PAC-MAC 2600

Remake using DIV Games studio

Started: 29/03/2015 20:26

***/
program pac2600;
const
redpath=82;
bluepath=156;
greenpath=214;
global sounds[10];
ghostcol[4]=209,110,121,122;


player=0;
start=0;
playing=false;
score=0;
gactive=0;
powertime=0;
powersound=0;
numghosts=4;
flicker=1;
demo=1;
lives=0;
ghostpoints=0;
res=-1;
cart=0;
pacspeed=2;
ghostspeed=2;
ghostfpg[4];

new_palette[255];
numfpg;
numfnt;
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

numfnt=load_fnt("atarinum.fnt");
cart=load_map("gfx/cart.pcx");
graph=cart;
x=160;
y=100;
//put_screen(file,cart);
frame(10000);
fade(0,0,0,10);
while(fading)
frame;
end

graph=0;

load_fpg("pac2600.fpg");
load_pal("pac2600.fpg");

fade(100,100,100,10);
define_region(1,0,0,320,168);

sounds[0]=load_wav("sounds/CHOMP.wav",0);
sounds[1]=load_wav("sounds/BOOP.wav",0);
sounds[2]=load_wav("sounds/START.wav",0);
sounds[3]=load_wav("sounds/DEATH.wav",0);
sounds[4]=load_wav("sounds/beeew.wav",1);
sounds[5]=load_wav("sounds/BUP_BWOOP.wav",0);
sounds[6]=load_wav("sounds/WHISTLE.wav",0);
set_mode(320200);

set_fps(60,0);
//x=198;
//    y=177;

write_int(numfnt,205,176,5,&score);
write_int(0,0,180,3,&lives);
//showscore();
from x = 0 to 4;
ghostfpg[x]=load_fpg("ghost.fpg");
end

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

            IF(powertime<=120)
                stop_sound(powersound);
            END
        END
        if(key(_enter) && demo==true)
            load_pal("pac2600.fpg");
            demo=false;
            playing=false;
            score=0;
            lives=3;
            signal(type maze, s_kill_tree);
            maze();
        end

    END

    signal(type maze, s_kill_tree);

    if(powertime>0)
        stop_sound(powersound);
        powertime=0;
    end
    if(lives<9)
        lives++;
    end
END

END



PROCESS maze()

PRIVATE
px;
py;


BEGIN

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

    get_point(file,101,6,&px,&py);
    bonus(px,py);


LOOP
    put_screen(file,100);

    // position pacman
    if(!demo)
    get_point(file,101,5,&px, &py);
    player=pac(px,py);
    else
    player=id;
    end

    // position ghosts
    get_point(file,101,7,&px, &py);

    for( x = 1 ;x<=numghosts;x++);
        ghost(px,py,x-1);
    END

    if(demo)
    frame(10000);
    playing=true;
    end

    frame;

    WHILE(get_id(type pac) || demo)

        if(demo)
            frame(10000);

            roll_palette(1,254,rand(0,255));
        else
            FRAME;
        end

    END

    signal(type ghost, s_kill);
    signal(type pac, s_kill);

    lives--;
    if(lives<1)
        demo=1;
    end
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
//resolution=res;
region=1;
FRAME(6000);

start = sound(sounds[2],255,255);

LOOP

    IF(playing==true || !is_playing_sound(start))
        playing=true;

        ox=x;
        oy=y;
        IF(key(_left))
            nx=-pacspeed;
            ny=0;
        END

        IF(key(_right))
            nx=pacspeed;
            ny=0;
        END

        IF(key(_up))
            nx=0;
            ny=-pacspeed;
        END

        IF(key(_down))
            ny=pacspeed;
            nx=0;
        END
        x+=nx;
        y+=ny;

        p=map_get_pixel(file,101,x,y-1);
        IF((x!=ox || y!=oy) && p!=0 && p!=greenpath && y>2 && y<200)
            dx=nx;
            dy=ny;
        ELSE
            x=ox;
            y=oy;
            x=x+dx;
            y=y+dy;
            p=map_get_pixel(file,101,x,y-1);

            if(dx==0 && dy!=0 && (y<2 || y>190))

            if(y>200)
                y=-20;
            end

            if(y<-20)
                y=200;
            end

            else

            IF(p==0 || p==greenpath)
                x=ox;
                y=oy;
                dx=0;
                dy=0;
            END
            end

        END

    END

    if(dx!=0 && dx!=ox)
        if(dx<0)
            flags=1;
        else
            flags=0;
        end
    end

    IF(anim++>10)
        anim=0;
        animf++;

        IF(animf==4)
            animf=0;
        END

        graph=frames[animf];

    END
    g=collision(type ghost);
    IF(g && y>0 && y<168)
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
            score+=ghostpoints;
            ghostpoints*=2;

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
targetx=0;
targety=0;
gfile=0;
ograph=0;
try1=0;
sw=0;
BEGIN
    homex=x;
    homey=y;
    gfile=ghostfpg[gid];

    file=gfile;
    from x = 0 to 255;
    new_palette[x]=x;
    end
    new_palette[179]=ghostcol[gid];
    from x = 1 to 4;
    convert_palette(file,x,&new_palette);
    end

    x=homex;

    dx=1;
    graph=1;

    resolution=res;
    region=1;
//    write_int(0,0,gid*20,0,&targetx);
//    write_int(0,40,gid*20,0,&targety);

    LOOP
        if(powertime<1 && eyes==0)
        file=gfile;
        else
        file=0;
        end
        IF(playing || eyes)
            p = map_get_pixel(0,101,x,y-1);

            IF(p==bluepath)
                ox=dx;
                oy=dy;
                dx=0;
                dy=0;
            END

        //    if(eyes)
                try1=4;
        //    else
        //        try1=0;
        //    end

            WHILE(dx==0 && dy==0)

                IF(try1>0 && ( eyes || rand(0,gid)==gid))
                    switch(try1)

                    case 1:
                    IF(targetx>x)
                        dx=1;
                    END
                    end

                    case 2:
                    if(targetx<x && dx==0)
                        dx=-1;
                    END
                    end

                    case 3:
                    if(targety<y && dx==0)
                        dy=-1;
                    END
                    end

                    case 4:

                    if(targety>y && dx==0 && dy==0)
                        dy=1;
                    END

                    end

                    end

                ELSE

                sw=rand(0,3);

                SWITCH(sw)

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
                END

                if(dx!=0 || dy!=0)


                p=map_get_pixel(0,101,x+dx,y-1+dy);
                IF(p==0 || (!eyes && p==greenpath && dx==-1) )
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

            IF(graph==5)
                graph=1;
            END
        END

        ograph=graph;

        IF(eyes==true)
            graph=5;
         //   file=1;
        END

        if(flicker)
            size=100*(gid%4==gactive);
      //  else
       //     flags=4;
        end

        IF(powertime>120)
            graph+=10;
        END
        if(powertime>0 || eyes)
            graph+=29;
        end
        if(!eyes)
        if(powertime>0)
            targetx=320*(gid==0 || gid ==2 );
            targety=200*(gid==0 || gid ==3 );
        else

           targetx=player.x;
           targety=player.y;
        end

        else
           targetx=homex;
           targety=homey;
        end



        FRAME;
        //(100/(1+eyes));

        graph=ograph;



    END

END



PROCESS wafer(x,y)

BEGIN

    graph=20;
    resolution = res;
    REPEAT
        FRAME;
    UNTIL (player.y-1==y && abs(player.x-(x+4))<5)

    sound(sounds[0],255,255);

    score++;

END



PROCESS powerpill(x,y)

BEGIN
graph=21;
resolution=res;
REPEAT

    size=100*((timer/20)&1);

    FRAME;

UNTIL(abs(x-player.x)<2 && abs(y-player.y)<2)

stop_sound(powersound);

sound(sounds[1],255,255);
score+=5;
ghostpoints=20;
powersound=sound(sounds[4],255,255);
powertime=600;
while((x=get_id(type ghost)))
x.dx=-x.dx;
x.dy=-x.dy;
end


END



PROCESS bonus(x,y)

BEGIN

graph=0;

LOOP
    if(graph==0)
        if(rand(0,1000)==0)
            graph=22;
        end
    else


        if(collision(type pac))
            if(abs(x-player.x)<5)
                score+=100;
                sound(sounds[1],255,255);
                graph=0;
            end
        end

    end

    frame;

END

END

process showscore()
private
tscore=0;
nscore=0;

BEGIN

numfpg=load_fpg("number.fpg");
   write_int(0,0,0,0,&tscore);

    from x = 0 to 255;
    new_palette[x]=x;
    end

    new_palette[201]=1;//ghostcol[gid];
    new_palette[254]=252;

    from x = 10 to 19;
    convert_palette(numfpg,x,&new_palette);
    end

    file=numfpg;

    graph=10;


    loop
    x=198;
    y=177;
    tscore=score;
    nscore=tscore;
    while(tscore>0)
    nscore=tscore%10;

    if(tscore>0 || x==198)
  //  debug;
    xput(file,nscore+10,x,y,angle,100,0,0);
    end
    x-=16;
   // tscore-=nscore;
    tscore=tscore/10;
    end

    frame;
    end
end

