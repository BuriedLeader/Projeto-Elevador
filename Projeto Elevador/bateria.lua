local bateria = {}

function bateria.load()
-- cores da bateria
CB1 = 0.15
CB2 = 0.9
CB3 = 0
-- valores atualizados
count6 = 0 -- contador pras barras diminuírem
barras = 4
Carregando = false
count7 = 0 -- tempo que o aviso vai ficar
MostraAviso = false
-- imagens
aviso = love.graphics.newImage('Imagens/Aviso.png') -- aviso de necessidade de manutenção
end
function bateria.update(dt)
  --timer de 10 segundos pro aviso ficar na tela
  if MostraAviso == true then
    count7 = count7 + dt
  end
  if love.keyboard.isDown('m') and EstadoAtual == elevador then
    barras = barras + 0.02
    Carregando = true
  end
  -- diminuidor de barra (1 barra a cada 30s)
  count6 = count6 + dt
  if count6 >= 30 and Carregando == false then
    barras = barras - 1
    count6 = 0
  end
-- verde
  if barras >= 3 then
    CB1 = 0.15
    CB2 = 0.9
    CB3 = 0
    vmax = 240
    MostraAviso = false
    count7 = 0 
  end
-- amarela
  if barras >= 2 and barras < 3 then
    CB1 = 0.81
    CB2 = 0.69
    CB3 = 0.08
    vmax = 120
    MostraAviso = true
  end
-- vermelha
  if barras <= 1 then
    CB1 = 0.66
    CB2 = 0.1
    CB3 = 0.04
  end
  if barras < 0 then
    barras = 0
  elseif barras > 4 then
    barras = 4
  end

end


function bateria.draw()
-- corpo da bateria
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle('fill',15,35,10,5) -- "cabeça"
  love.graphics.rectangle('line',10,40,20,50) -- "tronco"
-- barras
  love.graphics.setColor(CB1,CB2,CB3)
  -- quantas barras aparecem
  if barras >= 4 then
  love.graphics.rectangle('fill',13,45,14,6)
  end
  if barras >= 3 then
  love.graphics.rectangle('fill',13,56,14,6)
  end
  if barras >= 2 then
  love.graphics.rectangle('fill',13,67,14,6)
  end
  if barras >= 1 then
  love.graphics.rectangle('fill',13,78,14,6)
  end
  -- mostra o aviso por 10 segundos
  if MostraAviso == true and count7 <= 10 then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(aviso,250,200)
  end
  
end
return bateria