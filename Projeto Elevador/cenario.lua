local cenario = {}
JanelaDireita = {}
JanelaEsquerda = {}
JanelaEsquerdaPrimeiroAndar ={}
JanelaDireitaUltimoAndar = {}
JanelaEsquerdaUltimoAndar = {}
Terraco = {}
function cenario.load()
  -- fonte
  FontePlaca = love.graphics.newFont("Sweet Talk.otf",18)
  -- imagens
  mesa = love.graphics.newImage("Imagens/mesa.png")
  vaso = love.graphics.newImage("Imagens/vaso.png")
  frameJ = 1
  for i = 1, 3 do
    JanelaDireita[i] = love.graphics.newImage('Imagens/JD'..tostring(i)..'.png') -- janela direita genérica
  end
  for i = 1, 3 do
    JanelaEsquerda[i] = love.graphics.newImage('Imagens/JE'..tostring(i)..'.png') -- janela esquerda genérica
  end
  for i = 1, 3 do
    JanelaEsquerdaPrimeiroAndar[i] = love.graphics.newImage('Imagens/JEA'..tostring(i)..'.png') -- janela esquerda do primeiro andar
  end
  for i = 1, 3 do
    JanelaEsquerdaUltimoAndar[i] = love.graphics.newImage('Imagens/JEU'..tostring(i)..'.png') -- janela esquerda do ultimo andar
  end
  for i = 1, 3 do
    JanelaDireitaUltimoAndar[i] = love.graphics.newImage('Imagens/JDU'..tostring(i)..'.png') -- janela direita do último andar
  end
  for i = 1, 3 do
    Terraco[i] = love.graphics.newImage('Imagens/terraco'..tostring(i)..'.png') -- terraço
  end
  Aviao = love.graphics.newImage('Imagens/aviao.png')
  parede  = love.graphics.newImage("Imagens/Parede.jpg")
  piso  = love.graphics.newImage("Imagens/Piso.jpg")
  maquinas = love.graphics.newImage('Imagens/motor.png')
  roldana = love.graphics.newImage('Imagens/roldana3.png')
  -- valores atualizados
  count5 = 0 -- contador de passagem de tempo
  R = 0 -- rotação da polia
  PosAviao = -40  -- posição do avião
end

function JDireita(x,y) -- janela direita genérica
  love.graphics.setColor(1,1,1)
  love.graphics.draw(JanelaDireita[frameJ],x,y,0,0.3,0.3)
end

function JEsquerda(x,y) -- janela esquerda genérica
  love.graphics.setColor(1,1,1)
  love.graphics.draw(JanelaEsquerda[frameJ],x,y,0,0.3,0.3)
end

function JE1oAndar(x,y) -- janela esquerda do 1° andar
  love.graphics.setColor(1,1,1)
  love.graphics.draw(JanelaEsquerdaPrimeiroAndar[frameJ],x,y,0,0.3,0.3)
end

function JEultimo(x,y) -- janela esquerda do último andar
  love.graphics.setColor(1,1,1)
  love.graphics.draw(JanelaEsquerdaUltimoAndar[frameJ],x,y,0,0.3,0.3)
end

function JDultimo(x,y) -- janela direita do último andar
  love.graphics.setColor(1,1,1)
  love.graphics.draw(JanelaDireitaUltimoAndar[frameJ],x,y,0,0.3,0.3)
end

function placa(x,y,texto)
  love.graphics.setColor(0.54,0.33,0.06)
  love.graphics.rectangle("fill",x,y,70,30)
  love.graphics.setFont(FontePlaca)
  love.graphics.setColor(1,1,1)
  love.graphics.print(texto,(x+10),(y+10))
end
function BotaoElevador(x,y)
-- cor cinza
  love.graphics.setColor(0.65,0.65,0.65)
  love.graphics.circle("fill",x,y,8)
  
-- circunferência preta ao redor
  love.graphics.setColor(0.15,0.15,0.15)
  love.graphics.circle("line",x,y,9)
end
function cenario.update(dt)
  -- Aviao
  if frameJ == 1 then
  PosAviao = PosAviao + 90*dt
    if PosAviao >= 830 then
      PosAviao = 830
    end
  end

  -- passar tempo janela
  count5 = count5 + dt
  
  if count5 >=  30 then
    frameJ  = frameJ+1
      if frameJ > 3 then
        PosAviao = -40
        frameJ = 1
      end
    count5 = 0
  end


end
function Chao (x,y,X,Y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(piso,x,y,0,X,Y)
end
function andar(z) -- z é o número do andar
  Nandar = tostring(z).."° andar" -- nome do andar
  altura = 550 - 310*(z)
  love.graphics.draw(parede,0,altura-310,0,0.532,0.425)
  Chao(1,altura,0.585,0.1)
  if z == 1 then
   JE1oAndar(50,altura-170)
   JDireita(250,altura-170)
  elseif z > 1 and z < 10 then
  JEsquerda(50,altura-170)
  JDireita(250,(altura-170))
  elseif z == 10 then
  JEultimo(50,altura-170)
  JDultimo(250,(altura-170))
  end
  BotaoElevador(570,(altura-60))
  if z>0 then
    placa(470,(altura-120),Nandar)
 elseif z == 0 then
    placa(470,(altura-120),"Térreo")
  end
end

function contrapeso()
  love.graphics.setColor(1,1,1)
  love.graphics.line(653,(-2865),653,(-2839-Yelevador+350))
  love.graphics.setColor(0.2,0.03,0)
  love.graphics.rectangle('fill',617,(-2840-Yelevador+350),70,100)
end
function cenario.draw()
  -- Fundo do Elevador
  love.graphics.setColor(0.15,0.33,0.50)
  love.graphics.rectangle("fill",600,-2840,200,3440)
  love.graphics.setColor(1,1,1)
  --construação andares
  for i = 0, 10, 1 do
  andar(i)
  end
  --terraco
  love.graphics.draw(Terraco[frameJ],0,-3370,0,800/1253,600/846)
  

  --Teto do décimo andar
  love.graphics.setColor(1,1,1)
  love.graphics.draw(maquinas, 500, -2925, 0, 1, 1)
  love.graphics.draw(roldana, 670, -2865,R, 1/8, 1/8, roldana:getWidth()/2, roldana:getHeight()/2)
  contrapeso()
  -- Mesa
  love.graphics.setColor(1,1,1)
  love.graphics.draw(mesa,145,480,0,1/2,1/3)
  
  -- Vaso de Planta
  love.graphics.setColor(1,1,1)
  love.graphics.draw(vaso,155,400,0,1/5,1/5)
  
  -- Aviao
  love.graphics.setColor(1,1,1)
  love.graphics.draw(Aviao,PosAviao,-3150,0,0.5,0.5)

end
return cenario