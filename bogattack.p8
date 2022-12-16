pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
--main

--tube vars
tubes={}
tube_num=0

--bog vars
bog_health=4
bog_dmgcount=15
boghealth_x=104
boghealth_y=0
bog_x=104
bog_y=64
bogx_v=0.5
bogy_v=1
hit_w=16
hit_h=32
bog_spr=00
bog_alive=true
bog_timer=100

--bog_bullets
bogbullets={}
bogbullet_num=128
bogbullet_ind=1

--star vars
topstars={}
midstars={}
botstars={}
star_num=4
top_v=.4
mid_v=.6
bot_v=.8

--ground vars
ground={}
ground_num=4
ground_v=1.5

--cloud vars
clouds={}
cloud_num=3
cloud_v=0.5

--hill vars
hills={}
hill_num=3
hill_v=0.7

--bird vars
bird_x=10
bird_y=10
bird_v=0
bird_spr=12
gravity=0.1
jump_force=2
pressed=false
bird_bar={}
vic_health=2
vichealth_x=0
vichealth_y=-2
vic_w=16
vic_h=16

--bullet vars
bullets={}
--creates the number of pullets in our pool.
bullet_num = 128
bullet_ind=1


--main menu title vars
title_y=27
title_tar=30
title_min=20
title_max=30

--end screen fx vars
end_time=0
end_y=-12
end_tar=22

score=0
best=0

win=false

state="menu"

--run once at start
function _init()
	--make all "objects"
	--	add_tube()
	for i=0,star_num do
		add_top(i*32)
		add_mid(i*32)
		add_bot(i*32)
	end
	--ground objs
	for i=0,ground_num do
		add_ground(i*32)
	end
	--cloud objs
	for i=0,cloud_num do
		add_cloud(i*128)
	end
	--hill objs
	for i=0,hill_num do
		add_hill(i*128)
	end
	--bullet objs
	for i=0, bullet_num do
	    add_bullet()
	end
	for i=0, bogbullet_num do
					add_bogbullet()
	end
end

--runs every frame
function _update60()
	if(state=="menu")then
		menu_update()
	elseif(state=="game")then
		game_update()
	elseif(state=="end")then
		end_update()
	end
end

--runs every frame
function _draw()
	if(state=="menu")then
		menu_draw()
	elseif(state=="game")then
		game_draw()
	elseif(state=="end")then
		end_draw()
	end
end

--resets all gameplay vars
function reset_game()
	gravity=0.1
	
	pressed=false

	title_y=27
	title_tar=30
	
	
	if(score>best) best=score

	score=0
	
	--resets birds position
	bird_x=10
	bird_y=10
	bird_v=0
	bird_spr=12
	vic_health=2
	
	--resets bog damage
	bog_x=104
	bog_y=64
	bog_dmgcount=0
	bogx_v=0.5
	bogy_v=1

	end_time=0
	end_y=-12
	end_tar=22	
	t_count=0
	
	state="game"
	
end

----------------------------
--make top★ obj
function add_top(_x)
	add(topstars,{
		x=_x,
		y=0
	})
end

--makes mid★ obj
function add_mid(_x)
	add(midstars,{
		x=_x,
		y=17
	})
end

--makes bot★ obj
function add_bot(_x)
	add(botstars, {
		x=_x,
		y=33	
	})
end

--make cloud obj
function add_cloud(_x)
	add(clouds,{
		x=_x,
		y=80
	})
end

--make ground obj
function add_ground(_x)
	add(ground,{
		x=_x,
		y=112
	})
end

--make hill obj
function add_hill(_x)
	add(hills,{
		x=_x,
		y=85
	})
end

--make tube obj
--function add_tube()
	--for i=0,tube_num do
		--add(tubes,{
		--x=100,
		--y=rnd(90),
		--hit_w=16,
		--hit_h=32,
		--x_v=0.5,
		--y_v=0.5,
		--alive=true
	--})
	--end
--end

--adds bog healthbars
function add_ebar()
	for i=0,bar_num do
		add(bogbars,{
			x=104,
			y=0		
		})
	end
end
---------------------------

---------------------------
--col b/t vic and bog
function bogcol(b_x,b_y,
	v_x,v_y,
 h_w,h_h)
 --if vic x is greater than/equal
 --to bog x
 	if(v_x+8>=b_x and
 				v_x<=b_x+h_w and
 				v_y+8>=b_y and
 				v_y<=b_y+h_h)then
 			return true
 	end
end
---------------------------

--check overlap bog/bullet
function b_bogcol(_b,b_x,b_y,
	h_w,h_h)
	if(_b.x>=b_x and
				_b.x<=b_x+h_w and
				_b.y>=b_y and
				_b.y<=b_y+h_h)then
		return true
	end
end

--col b/t bogbullet and vic
function v_overlap(_b,
	v_x,v_y,
	v_w,v_h)
	if(_b.x>=v_x and
				_b.x<=v_x+v_w and
				_b.y>=v_y and
				_b.y<=v_y+v_h)then
		return true
	end
end

--check overlap b/t bullet
--and tube
function b_overlap(_b,_t)
	if(_b.x>=_t.x and
				_b.x<=_t.x+_t.hit_w and
				_b.y>=_t.y and
				_b.y<=_t.y+_t.hit_h)then
		return true
	end
end

--gen lerp func for juice
function lerp(pos,tar,p)
	return(1-p)*tar+p*pos
end
-->8
--game state

function game_update()

------------------------------
--scrolls top layer ★
	for tp in all(topstars) do
		tp.x-=top_v
		if(tp.x<-32)then
			temp=tp
			tp.x=topstars[star_num+1].x+32
			del(topstars,tp)
			add(topstars,temp)
		end		
	end
------------------------------

------------------------------
--moves mid layer ★	
	for m in all(midstars) do
		m.x-=mid_v
		if(m.x<-32)then
			temp=m
			m.x=midstars[star_num+1].x+32
			del(midstars,m)
			add(midstars,temp)
		end		
	end
------------------------------

------------------------------	
--moves bottom layer ★
	for b in all(botstars)do
		b.x-=bot_v
		if(b.x<-32)then
			temp=b
			b.x=botstars[star_num+1].x+32
			del(botstars,b)
			add(botstars,temp)			
		end
	end
------------------------------
	
------------------------------	
	for g in all(ground) do
		g.x-=ground_v
		if(g.x<-32)then
			temp=g
			g.x=ground[ground_num+1].x+32
			del(ground,g)
			add(ground,temp)
		end
	end
------------------------------
		
------------------------------	
	for c in all(clouds) do
		c.x-=cloud_v
		if(c.x<-128)then
			temp=c
			c.x=clouds[cloud_num].x+128
			del(clouds,c)
			add(clouds,temp)
		end	
	end
------------------------------
		
------------------------------
	for h in all(hills) do
		h.x-=hill_v
		if(h.x<-128)then
			temp=h
			h.x=hills[hill_num].x+128
			del(hills,h)
			add(hills,temp)
		end	
	end
------------------------------

	bird_move()
	bog_move()
	bogtimer()
	
------------------------------
	if(bogcol(bog_x,bog_y,
	bird_x,bird_y,
	hit_w,hit_h))then
			sfx(1)
			vic_health-=1
	end
------------------------------		
	if(vic_health<=0)then
		state="end"
	end	

--if bird hits ground
	if(bird_y > 125)then
		sfx(1)
		state="end"		
	end
	
	if(btnp(2,0))then
		--add_bullet(bird_x+8,bird_y+4)
		bird_shoot(bird_x, bird_y)
		sfx(5)
	end
	
 -----------------------------
	--for every bullet
	for b in all(bullets)do
		
		----------------------------
		--if the bullet is visible
		if(b.visible)then
   --sends bullet to the left
   b.x+=b.v
   
   --------------------------
   if(b_bogcol(b,bog_x,bog_y,
			hit_w,hit_h))then
				b.visible=false
				bog_dmgcount+=1
			end --end of "if b_bogcol"
   --------------------------
   
   ---------------------------
   if(b.x>128)then
   	b.visible=false
   end
   ---------------------------
		end
		----------------------------
	end
 -----------------------------
	
	-----------------------------
	for bb in all(bogbullets)do
		if(bb.bogvisible)then
				bb.x-=bb.v
				
				if(v_overlap(bb,
						bird_x,bird_y,
						vic_w,vic_h))then
							bb.bogvisible=false
							vic_health-=1
				end
		end
	end
	-----------------------------
end

function game_draw()
	
--note to self, draw order
--is determined by the order
--in which objects are drawn
--in code.
	cls(0)

--scenery objs	
--draws top★
	for tp in all(topstars) do
		spr(44, tp.x,tp.y,4,2)
	end
--draws mid★	
	for m in all(midstars) do
		spr(44, m.x,m.y,4,2)
	end
--draws bot★
	for b in all(botstars) do
		spr(44,b.x,b.y,4,2)
	end
--draws clouds	
	for c in all(clouds) do
		spr(64,c.x,c.y,16,4)
	end
--draws hills	
	for h in all(hills) do
		spr(128,h.x,h.y,16,4)
	end
--draws tubes
	--for t in all(tubes) do
		--if(t.alive)then
			--spr(0,t.x,t.y,3,3)
		--end
	--end
--draws ground		
	for g in all(ground) do
		spr(8,g.x,g.y,4,4)
	end
	
	for b in all(bullets) do
		if(b.visible)then
		    circfill(b.x,b.y,1,8)
		end
	end
	
	for bb in all (bogbullets)do
		if(bb.bogvisible)then
				circfill(bb.x,bb.y,1,8)
		end
	end
	
	boghealth(bog_health,
		boghealth_x,
		boghealth_y)
		
	vichealth(vic_health,
		vichealth_x,
		vichealth_y)
		
	spr(bird_spr,bird_x,bird_y,2,2)
	spr(bog_spr,bog_x,bog_y,3,3)
	rectfill(64,10,66,14,7)
	print(score,64,10,0)

end

function vichealth(vic_health,
	_x,_y)
		if(vic_health==2)then
			spr(217,_x,_y,2,1)
		end
		if(vic_health==1)then
			spr(219,_x,_y,2,1)
		end
end

--draws bog's health bar
function boghealth(health,_x,_y)
	--if (health==4)then
	if(bog_dmgcount<4) then
		spr(249,_x,_y,3,1)
	end
	if(bog_dmgcount>=4 and
		bog_dmgcount<8)then
			spr(252,_x,_y,3,1)
	end
	if(bog_dmgcount>=8 and
		bog_dmgcount<12)then
			spr(233,_x,_y,3,1)
	end
	if(bog_dmgcount>=12 and
		bog_dmgcount<16)then
			spr(236,_x,_y,3,1)
	end
	if(bog_dmgcount>=16)then
		win=true
		state="end"
	end
end

function bird_move()
	
	bird_v+=gravity
	bird_y+=bird_v
	
	if(btn(4,0) and not pressed)do
		sfx(0)
		bird_v-=jump_force
		--bird_spr=14
		pressed=true
	end
	
	if(btn(0,0)) do
		bird_x-=1
		if (bird_x<0)do
		bird_x=0
		end
	end
	--if the right arrow is pressed
	if(btn(1,0)) do
		bird_x+=1 --moves bird right
		if(bird_x>112)do --if x is greater than 112
		bird_x=112 --clamps x position so it can't go over.
		end
	end
	
	if(not btn(4,0))then
		bird_spr=12
		pressed=false
	end
	
	if(bird_y<0)do
		bird_y=0
		bird_v=0
	end

end

function bird_shoot(_x,_y)
--set new bullet position
bullets[bullet_ind].x = _x+8
bullets[bullet_ind].y = _y+8
bullets[bullet_ind].visible=true
bullet_ind+=1
--increase the index of bullets
--
	if(bullet_ind>=bullet_num)then
	    bullet_ind=1
	end

end

function bog_move()
	
	bog_x-=bogx_v
	bog_y-=bogy_v

	--same for x dir, but for 
	--left or right of
	--screen.
	---------------------------
	if(bog_x>=104 
		or bog_x <= 0)then
			bogx_v=-bogx_v
	end
	---------------------------
			
	--reverse y dir if it
	--reaches the bottom or
	--top of screen.
	---------------------------
	if(bog_y>=104
		or bog_y<=0)then
			bogy_v=-bogy_v
	end
	---------------------------
	
	

end

function bogtimer()
	bog_timer-=1
	if (bog_timer <= 0)then
		bog_shoot(bog_x,bog_y)
		sfx(5)
		bog_timer=50
	end
end

function bog_shoot(_x,_y)
--set new bullet position
bogbullets[
	bogbullet_ind].x=_x+8
bogbullets[
	bogbullet_ind].y=_y+8
bogbullets[
	bogbullet_ind].bogvisible=true
bogbullet_ind+=1

	if(bogbullet_ind>
		bogbullet_num)then
			bogbullet_ind=1
	end
end

function add_bullet()
	add(bullets,{
		x=-10,
		y=-10,
		v=2,
		visible=false
	})
end

--adds bullets to bog bullet 
--table
----------------------------
function add_bogbullet()
	add(bogbullets,{
	x=-15,
	y=-15,
	v=2,
	bogvisible=false
	})
end
----------------------------`

-->8
--menu

function menu_update()

--scrols top★ right -> left
	for t in all(topstars) do
		t.x-=top_v
		if(t.x<-32)then
			temp=t
			t.x=topstars[star_num+1].x+32
			del(topstars,t)
			add(topstars,temp)
		end
	end
	
--scrolls mid★ right -> left
	for m in all(midstars) do
		m.x-=mid_v --moves ★ left
		--if out of bounds
		if(m.x<-32)then
			temp=m --creates temp obj
			--sets the position of m.x
			m.x=midstars[star_num+1].x+32
			--deletes original obj
			del(midstars,m)
			--replaces w/ temp obj
			add(midstars,temp)
		end		
	end
	
--moves bot★ right -> left
	for b in all(botstars)do
		b.x-=bot_v
		if(b.x<-32)then
			temp=b
			b.x=botstars[star_num+1].x+32
			del(botstars,b)
			add(botstars,temp)			
		end	
	end
		
--moves clouds right -> left
	for c in all(clouds) do
		c.x-=cloud_v	
		if(c.x<-128)then
			temp=c
			c.x=clouds[cloud_num].x+128
			del(clouds,c)
			add(clouds,temp)
		end
	end
		
--moves hills right -> left
	for h in all(hills) do
		h.x-=hill_v
		if(h.x<-128)then
			temp=h
			h.x=hills[hill_num].x+128
			del(hills,h)
			add(hills,temp)
		end
	end

--moves grounds right -> left	
	for g in all(ground) do
		g.x-=ground_v
		if(g.x<-32)then
			temp=g
			g.x=ground[ground_num+1].x+32
			del(ground,g)
			add(ground,temp)
		end
	end

--lerps title up and down
	bounce_title()
	
--changes state if x pressed
	if(btn(5,0)) state="game"
	
end

function menu_draw()

	cls(0)
	
	for t in all(topstars) do
		spr(44, t.x,t.y,4,2)
	end
	
	for m in all(midstars) do
		spr(44, m.x,m.y,4,2)
	end
	
	for b in all(botstars) do
		spr(44,b.x,b.y,4,2)
	end
	
	for c in all(clouds) do
		spr(64,c.x,c.y,16,4)
	end
		
	for h in all(hills) do
		spr(128,h.x,h.y,16,4)
	end
	
	for g in all(ground) do
		spr(8,g.x,g.y,4,4)
	end
	
	spr(192,28,title_y,9,2)
	
	print("press x to start",32,50,7)
	print("z to flap",47,60,7)
	print("left/right arrow to move",
	18,70,7)
	print("up arrow to shoot",
	32,80,7)

end

function bounce_title()
	
	title_y=lerp(title_y,title_tar,0.9)
	
	if(title_y>=title_max-0.5)then
		title_tar=title_min
	end
	
	if(title_y<=title_min+0.5)then
		title_tar=title_max
	end

end
-->8
--end

function end_update()
	
	if (win==false)then
		bounce_back()
	end
	
	if(win)then
		bog_bounce()
	end
	
	
	end_time+=1
	
	end_sfx()

	if(btn(5,0)) reset_game()
	
end

function end_draw()
	
	game_draw()

	rectfill(16,32,112,96,9)
	
	if(end_y<end_tar) end_y+=1
	
	spr(224,29,end_y,9,2)
	
	if (win)then
		print("you stopped bog!",35,50,0)
		print("x to play again",38,80,0)
	end
	
	---------------------------
	--if(end_time>35)then
		--print("score: "..score.."",45,50,0)
	--end
	---------------------------
	
	---------------------------
	--if(end_time>50)then
			--print("best: "..best.."",47,60,0)
	--end
	---------------------------
	
	if(win==false)then
		print("bog is victorious!",30,50,0)
		print("x to restart",38,80,0)
	end
	--if(end_time>65)then
			--print("x to restart",38,80,0)
	--end

end

function bounce_back()
	
	if(bird_y<128)then
		gravity=1.5
		bird_v+=gravity
		bird_x-=2+rnd(4)
		bird_y+=bird_v
	end

end

--juice for when bog dies.
function bog_bounce()
	gravity=1.5
	bogy_v+=gravity
	bog_x+=2+rnd(4)
	bog_y+=bogy_v
end

function end_sfx()
	
	if(end_time==5) sfx(4)
	
	if(end_time==35) sfx(2)
	
	if(end_time==50) sfx(2)
	
	if(end_time==65) sfx(2)

end
__gfx__
11111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000000000000000000000
11111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000011111000000000000000000000
11bbb7bbbbbbbbbb3110000000000000000000000000000000000000000000000000000000000000000000000000000000001166661100000000000000000000
11bbb8bbbbbb8bbb3110000000000000000000000000000000000000000000000000000000000000000000000000000000001166666169000000000000000000
11bbb78bbbb8bbbb3110000000000000000000000000000000000000000000000000000000000000000000000000000000116666666110000000000000000000
11bbb7b8bb8bbbbb3110000000000000000000000000000000000000000000000000000000000000000000000000000000816666666611000000000000000000
11bbb788bb88bbbb3110000000000000000000000000000000000000000000000000000000000000000000000000000000816666966661110000000000000000
11bbb788bb88bbbb3110000000000000000000000000000000000000000000000000000000000000000000000000000000116669999666610000000000000000
11111188118811111110000000000000000000000000000000000000000000001111111111111111111111111111111100116669999666610000000000000000
11111188118811111110000000000000000000000000000000000000000000001111116111111111111111111111111100816666966661110000000000000000
0011bb88bb88bb311000000000000000000000000000000000000000000000007777776777777777777777777777777700816666666611000000000000000000
0011bbbbbbbbbb31100000000000000000000000000000000000000000000000bbb6bbb33333333bbbbb6bb33333333b00116666666110000000000000000000
0011bbbbbbbbbb31100000000000000000000000000000000000000000000000bbbbb833333333bbbbbbb6333633338b00001166666169000000000000000000
0011bbbbbbbbbb31100000000000000000000000000000000000000000000000b6bbb33333333bbbb68bb33336333b6b00001166661100000000000000000000
0011bbbb11bbbb31100000000000000000000000000000000000000000000000bbbb33363333bbbbbbbb336333336bbb00000011111000000000000000000000
0011bbb1bb1bbb31100000000000000000000000000000000000000000000000bbb33333333bbbbbbbb33383336bbbbb00000011110000000000000000000000
0011bb17bb71bb311000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000000000000000000000
0011bbb7bb7bbb311000000000000000000000000000000000000000000000001111111111111111111111111111111100000000000000700700000000000000
0011bbbbbbbbbb311000000000000000000000000000000000000000000000004444444444444444444444444444444407000000000000000000000000000000
0011bbbbbbbbbb31100000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0011bbbbbbbbbb31100000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0011111111111111100000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000070000000000000007000000000
0011111111111111100000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff07000000000000000000000007000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000007000000000000700
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000007000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00070000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000077777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000007777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077777777777777777770000000000000000000000000000000000777777777000000000000000077777777700000000000000000
00000000000000000000000777777777777777777777000000000000000000000000000000777777777777777000000000007777777777777000000000000000
00000000000000000000007777777777777777777777700000000077777770000000000007777777777777777777000000777777777777777770000000000000
00000000077777777000077777777777777777777777770000077777777777770000000777777777777777777777700007777777777777777777000000000000
00000007777777777770077777777777777777777777770000777777777777777000007777777777777777777777770077777777777777777777700000000000
00000777777777777777777777777777777777777777777007777777777777777700077777777777777777777777777777777777777777777777770077777000
00007777777777777777777777777777777777777777777077777777777777777770077777777777777777777777777777777777777777777777777777777770
00077777777777777777777777777777777777777777777077777777777777777770777777777777777777777777777777777777777777777777777777777777
00777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
00777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
07777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
07777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000033333333333333300000000000000000000000000000000000000000000000000000000000000333333333300000000
00000000000000000000000000000000333333333333333110000000000000000000000000000000000000000000000000000000000033333333333333000000
00000000000000000000000000000000333333333333331110000000000000000000000000000000000000000000000000000000000333333333333331100000
33300000000000000000000000000000333333333333331110000000000000000000333333333300000000000000000000000000000333333333333311100333
33330000000000000000000000000000333333333333331110000000000000000033333333333333000000000000000000000000000333333333333311103333
33331000000000000000000000000000333333333333331110000000000000003333333333333333110000000000000000000000000333333333333311133333
33311000000003333333330000000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311113333
33311000000333333333333300000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311111333
33311000003333333333333110000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311111333
33311000003333333333331110000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311111333
33311000003333333333331110000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311111333
33311000003333333333331110000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311111333
33311000003333333333331110000000333333333333331110000000000000003333333333333331110000000000000000000000000333333333333311111333
33311000003333333333331110003333333333333333331110000000000000003333333333333331110000000033333333333000000333333333333311111333
33311000003333333333331110333333333333333333331110000003333330003333333333333331110000003333333333333310000333333333333311111333
33311000003333333333331113333333333333333333331110000033333331003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111333333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
33311000003333333333331111133333333333333333331110000033333311003333333333333331110000033333333333333111000333333333333311111333
77777777777777777777777777077777777777777777777777777777777777777777777700000000000000000000000000000000000000000000000000000000
71111111111111111111111117077111111777111177111177111111117711111111111700000000000000000000000000000000000000000000000000000000
71bbbbbb1bbbbb1bbbbbbbbb170711bbbb11771bb1771bb1771bbbbbb1711bb1bb11bb1700000000000000000000000000000000000000000000000000000000
71bbbbbb1bbbbb1bbbbbbbbb17071bbbbbb1771bb1771bb1771bbbbbb171bbb1bb1bbb1700000000000000000000000000000000000000000000000000000000
71bbb1bb1bbbbb1bbbbbbbbb17071bbbbbb1771bb1111bb1111bbbbbb111bbb1bbbbbb1700000000000000000000000000000000000000000000000000000000
71bbbbbb1bbbbb1bbb11111117071bb11bb1771bb1bbbbbbbb11111bbb1bbb11bbbbb11700000000000000000000000000000000000000000000000000000000
71bbbbb11bb1bb1bbb1bbbbb17071bb11bb1111bb1111bb1111bbbbbbb1bb171bbb1111700000000000000000000000000000000000000000000000000000000
71333333133333133313333317071333333133333333133177133333331317713331111700000000000000000000000000000000000000000000000000000000
71333133133333133311113317071333333111133111133177133113331331713333311700000000000000000000000000000000000000000000000000000000
71333333133333133333333317071333333177133177133177133333331333113333331700000000000000000000000000000000000000000000000000000000
71333333133333133333333317071331133177133177133177133333331133313313331711111111111111111111111111111111111111111111111100000000
7133333313333313333333331707133113317713317713317713333333111331331133171cccccccc1ccccc11cccccccc1555551155555555155555100000000
7111111111111111111111111707111111117711117711117711111111171111111111171ccccccc1cccccc11ccccccc15555551155555551555555100000000
7777777777777777777777777707777777777777777777777777777777777777777777771cccccc1ccccccc11cccccc155555551155555515555555100000000
0000000000000000000000000000000000000000000000000000000000000000000000001ccccc1cccccccc11ccccc1555555551155555155555555100000000
00000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111100000000
77777777777777777777777777777777777700077777777777777777777777000000000011111111111111111111111111111111111111111111111100000000
71111111111111111111111111111111111700071111111111111111111117000000000018888881888888155555515118888881555555155555515100000000
71bbbbbbbb1bbbbbb1bbbbbbbbbb1bbbbb1700071bbbbb1bbb1bbb1bbbbb17777777700018888818888881555555155118888815555551555555155100000000
71bbbbbbbb1bbbbbb1bbbbbbbbbb1bb1bb1700071bbbbb1bbb1bbb1bb1bb11111111700018888188888815555551555118888155555515555551555100000000
71bbbbbbbb1bbbbbb11bbbbbbbbb1bbbbb1700071bbbbb1bbb1bbb1bbbbb1bbbbbb1700018881888888155555515555118881555555155555515555100000000
71bbb1111111111bbb1bbbbbbbbb1bbbbb1700071bbbbb1bbb1bbb1bbbbb1bbbbbb1700018818888881555555155555118815555551555555155555100000000
71bbb1bbbb1bbbbbbb1bbb1bbb1b1bb1111700071bb1bb1bbb1bbb1bb1111bbb1bb1700018188888815555551555555118155555515555551555555100000000
71333133331333333313331333131331777700071333331333133313317713331111700011111111111111111111111111111111111111111111111100000000
71333111331331133313331333131331777700071333331333133313317713331777700011111111111111111111111111111111111111111111111100000000
71333333331333333313331333131331111700071333331333333313311113331700000018888881888888188888818118888881888888188888815100000000
71333333331333333313331333131333331700071333331333333313333313331700000018888818888881888888188118888818888881888888155100000000
71333333331333333313331333131333331700071333331333333313333313331700000018888188888818888881888118888188888818888881555100000000
71111111111111111111111111111111111700071111111111111111111111111700000018881888888188888818888118881888888188888815555100000000
77777777777777777777777777777777777700077777777777777777777777777700000018818888881888888188888118818888881888888155555100000000
00000000000000000000000000000000000000000000000000000000000000000000000018188888818888881888888118188888818888881555555100000000
00000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111111111111111111100000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777777777777777777777777777777777777ccc7777777777777777cccc777777777ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc711111111111111111171111771111711111117ccc7111111111111117cccc711111117ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc71bbbbbb1bb1bbbbbb171bb1771bb171bb1bb17ccc71bbbbbb1bbbbb17777771bbbbb17ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc71bbbbbb1bb1bbbbbb111bb1111bb111bb1bb17ccc71bbbbbb1bbbbb11111111bbbbb17ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc71bb11111bb1bbbbbb1bbbbbbbbbbbb1bb1bb17ccc71bbb1bb1bbbbb1bbbbbb1bb1bb17ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc71bbbbbb1bb11111bb111bb1111bb111bb1bb17ccc71bbbbbb1bbbbb1bbbbbb1bbbbb17ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc71bbbbbb1bb1bbbbbb171bb1771bb171bb1bb17ccc71bbbbb11bb1bb1bbb1bb1bbbbb17ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc713333331331333333171331771331713313317ccc71333333133333133311113311117ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc713311111331331133171331771331713333317ccc71333133133333133317713317777ccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc713317771331333333171331771331713333317ccc71333333133333133317713317cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc713317c71331333333171331771331711113317ccc71333333133333133317713317cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc713317c71331333333171331771331713333317ccc71333333133333133317713317cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc711117c71111111111171111771111711111117ccc71111111111111111117711117cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccc777777c77777777777777777777777777777777ccc77777777777777777777777777cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc777c777c777cc77cc77ccccc7c7ccccc777cc77cccccc77c777c777c777c777ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc7c7c7c7c7ccc7ccc7ccccccc7c7cccccc7cc7c7ccccc7cccc7cc7c7c7c7cc7cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc777c77cc77cc777c777cccccc7ccccccc7cc7c7ccccc777cc7cc777c77ccc7cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc7ccc7c7c7ccccc7ccc7ccccc7c7cccccc7cc7c7ccccccc7cc7cc7c7c7c7cc7cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccc7ccc7c7c777c77cc77cccccc7c7cccccc7cc77cccccc77ccc7cc7c7c7c7cc7cccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc000ccccc000cc00ccccc000c0ccc000c000cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc0cccccc0cc0c0ccccc0ccc0ccc0c0c0c0cccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccc0ccccccc0cc0c0ccccc00cc0ccc000c000cccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc0cccccccc0cc0c0ccccc0ccc0ccc0c0c0cccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccc000cccccc0cc00cccccc0ccc000c0c0c0cccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777777777ccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc7777777777777ccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc77777777777777777ccccccccccccccccccc
cccccccccccccccc777777777cccccccccccccccc777777777ccccccccccccccccccccccccccccccccccccccccc7777777777777777777cccccccccccccccccc
ccccccccccccc777777777777777ccccccccccc7777777777777cccccccccccccccccccccccccccccccccccccc777777777777777777777ccccccccccccccccc
cccccccccccc7777777777777777777cccccc77777777777777777ccccccccccccccccccccccccccccccccccc77777777777777777777777ccccccccc7777777
777ccccccc7777777777777777777777cccc7777777777777777777ccccccccccccccccccccc77777777cccc7777777777777777777777777ccccc7777777777
7777ccccc777777777777777777777777cc777777777777777777777cccccccccccccccccc777777777777cc7777777777777777777777777cccc77777777777
77777ccc7777777777777777777777777777777777777777777777777cc77777cccccccc777777777777777777777777777777777777777777cc777777777777
777777cc7777777777777777777777777777777777777777777777777777777777ccccc7777777777777777777777777777777777777777777c7777777777777
777777c777777777777777777777777777777777777777777777777777777777777ccc77777777333333333337777777777777777777777777c7777777777777
7777777777777777777777777333333333377777777777777777777777777777777cc77777773333333333333337777777777777777777777777777777777777
7777777777777777777777733333333333333777777777777777777777777777777cc77777733333333333333311777777777777777777777777777777777777
7777777777777777777777333333333333331177777777777777777777777777777c777777733333333333333111777777777777777777777777777777777777
7777777777777777777777333333333333311177333333777777777777777777777c777777733333333333333111777777777777777777733333333337777777
77777777777777777777773333333333333111733333333777777777777777777777777777733333333333333111777777777777777773333333333333377777
77777777777777777777773333333333333111333333333177777777777777777777777777733333333333333111777777777777777333333333333333311777
77777777777777777777773333333333333111133333331177777777333333333777777777733333333333333111777777777777777333333333333333111777
77777777777777777777773333333333333111113333331177777733333333333337777777733333333333333111777777777777777333333333333333111777
77777777777777777777773333333333333111113333331177777333333333333311777777733333333333333111777777777777777333333333333333111777
77777777777777777777773333333333333111113333331177777333333333333111777777733333333333333111777777777777777333333333333333111777
77777777777777777777773333333333333111113333331177777333333333333111777777733333333333333111777777777777777333333333333333111777
77777777777777777777773333333333333111113333331177777333333333333111777777733333333333333111777777777777777333333333333333111777
77777777777777777777773333333333333111113333331177777333333333333111777777733333333333333111777777777777777333333333333333111777
77777333333333337777773333333333333111113333331177777333333333333111777333333333333333333111777777777777777333333333333333111777
77733333333333333177773333333333333111113333331177777333333333333111733333333333333333333111777777333333777333333333333333111777
77333333333333331117773333333333333111113333331177777333333333333111333333333333333333333111777773333333177333333333333333111777
77333333333333331117773333333333333111113333331177777333333333333111133333333333333333333111777773333331177333333333333333111777
77333333333333331117773333333333333111113333331177777333333333333111113333333333333333333111777773333331177333333333333333111777
77333333333333331117773333333333333111113333331177777333333333333111113333333333333333333111777773333331177333333333333333111777
77333333333333331117773333333333333111113333331177777333333333333111113333333333333333333111777773333331177333333333333333111777
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
b33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbb
33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb
3333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb3
333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33
33333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb33333333bbbbbbbb333
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

__gff__
0000000000000000000000000000000000008080000000000000000000000000000080800000000000000000000000000000808000000000000000000000000000008080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0402000014051160511a0511d05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
940400000705106051060531105300000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000
570900001505309053000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5c05000022154251542a154000000000000000000000000000000000000000000000000001b200272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001b1511a151141511a151191511315115151151510b1000a1000a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0810000038900389003895037950349403390030900309003190028800278002780016d0021900239001c9001d9001c2002020002e0004e000de001ce0025e0030e001e900209002390000000249002790000000
00100000000000e400166500b6501e65000000000000000000000000000000000000000000000015600186001b6001c6001e6001f600226002260023600236002460000000000000000000000000000000000000
0010000000000000000000000000042500d25017250232502c2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
