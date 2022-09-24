local menu = {}
-- Dimensões dos botões
local Botao_Iniciar = {
  x = 282,
  y = 202,
  w = 288,
  h = 86
  }
local Botao_Ajuda = {
  x = 285.2,
  y = 324,
  w = 288,
  h = 86
}
local Botao_Sair = {
  x = 288,
  y = 453,
  w = 288,
  h = 86
}
local Botao_Sair_Ajuda = {
  x = 10,
  y = 15,
  w = 90,
  h = 85
}
local Botao_Passar_Pagina = {
  x = 710,
  y = 15,
  w = 90,
  h = 85
}
local Botao_Voltar_Pagina = {
  x = 10,
  y = 15,
  w = 90,
  h = 85
}
local Botao_ModoOffline = {
  x = 20,
  y = 20,
  w = 365,
  h = 100
}
local Botao_ModoOnline = {
  x = 420,
  y = 20,
  w = 365,
  h = 100
}
function menu.load()
  ModoOn = false
  ModoOff = false
  InterfacePrincipal = love.graphics.newImage("Imagens/menu.png")
  InterfaceAjuda1 = love.graphics.newImage("Imagens/Ajuda1.png")
  InterfaceAjuda2 = love.graphics.newImage("Imagens/Ajuda2.png")
  InterfaceEscolha = love.graphics.newImage('Imagens/EscolheModo.png')
  MenuEscolha = false
  MenuAjuda = false
  Pagina2Ajuda = false
end

-- Função para criar botão
function botao(x,y,w,h)
  love.graphics.setColor(1,1,1,0)
  love.graphics.rectangle('line', x, y, w, h)
end

function mouse_botao(mx, my, x, y, w, h)
  return mx >= x and mx <= x + w and my >= y and my <= y + h 
end

-- Funcionalidade dos botões
function menu.mousepressed(x, y, botao)
  -- No menu principal
  if MenuAjuda == false and Pagina2Ajuda == false and MenuEscolha == false then
    if botao == 1 and mouse_botao(x, y, Botao_Iniciar.x, Botao_Iniciar.y, Botao_Iniciar.w, Botao_Iniciar.h) then 
      MenuEscolha = true
    elseif botao == 1 and mouse_botao(x, y, Botao_Ajuda.x, Botao_Ajuda.y, Botao_Ajuda.w, Botao_Ajuda.h) then 
        MenuAjuda = true
    elseif botao == 1 and mouse_botao(x, y, Botao_Sair.x, Botao_Sair.y, Botao_Sair.w, Botao_Sair.h) then 
        love.event.quit()
    end
  -- No menu ajuda (primeira página)
  elseif MenuAjuda == true and Pagina2Ajuda == false and MenuEscolha == false then
    if botao == 1 and mouse_botao(x, y, Botao_Sair_Ajuda.x, Botao_Sair_Ajuda.y, Botao_Sair_Ajuda.w, Botao_Sair_Ajuda.h) then
      MenuAjuda = false
    elseif botao == 1 and mouse_botao(x, y, Botao_Passar_Pagina.x, Botao_Passar_Pagina.y, Botao_Passar_Pagina.w, Botao_Passar_Pagina.h) then
      Pagina2Ajuda = true
      MenuAjuda = false
    end
  -- No menu ajuda (segunda página)
  elseif MenuAjuda == false and Pagina2Ajuda == true and MenuEscolha == false then
    if botao == 1 and mouse_botao(x, y, Botao_Voltar_Pagina.x, Botao_Voltar_Pagina.y, Botao_Voltar_Pagina.w, Botao_Voltar_Pagina.h) then
      MenuAjuda = true
      Pagina2Ajuda = false
    end
  -- No menu escolha
  elseif MenuAjuda == false and Pagina2Ajuda == false and MenuEscolha == true then
    if botao == 1 and mouse_botao(x, y, Botao_ModoOffline.x, Botao_ModoOffline.y, Botao_ModoOffline.w, Botao_ModoOffline.h) then
      ModoOff = true
      ModoOn = false
      VaiPraSimu()
    elseif botao == 1 and mouse_botao(x, y, Botao_ModoOnline.x, Botao_ModoOnline.y, Botao_ModoOnline.w, Botao_ModoOnline.h) then
      ModoOn = true
      ModoOff = false
      VaiPraSimu()
    end
  end
end

function menu.update(dt)
  
end
  
  -- Desenhar as interfaces e os botões
function menu.draw()
  -- Menu Principal
  if MenuAjuda == false and Pagina2Ajuda == false and MenuEscolha == false then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(InterfacePrincipal,0,0)
    botao(Botao_Iniciar.x, Botao_Iniciar.y, Botao_Iniciar.w , Botao_Iniciar.h)
    botao(Botao_Ajuda.x, Botao_Ajuda.y, Botao_Ajuda.w , Botao_Ajuda.h)
    botao(Botao_Sair.x, Botao_Sair.y, Botao_Sair.w , Botao_Sair.h)
  -- Menu Ajuda (Primeira página)
  elseif MenuAjuda == true and Pagina2Ajuda == false and MenuEscolha == false then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(InterfaceAjuda1,0,0,0,1,1)
    botao(Botao_Sair_Ajuda.x, Botao_Sair_Ajuda.y, Botao_Sair_Ajuda.w, Botao_Sair_Ajuda.h)
    botao(Botao_Passar_Pagina.x, Botao_Passar_Pagina.y, Botao_Passar_Pagina.w, Botao_Passar_Pagina.h)
  -- Menu Ajuda (Segunda página)
  elseif MenuAjuda == false and Pagina2Ajuda == true and MenuEscolha == false then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(InterfaceAjuda2,0,0,0,1,1)
    botao(Botao_Voltar_Pagina.x, Botao_Voltar_Pagina.y, Botao_Voltar_Pagina.w, Botao_Voltar_Pagina.h)
  -- Menu Escolha
  elseif MenuAjuda == false and Pagina2Ajuda == false and MenuEscolha == true then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(InterfaceEscolha,0,0,0,1,1)
    botao(Botao_ModoOffline.x, Botao_ModoOffline.y, Botao_ModoOffline.w, Botao_ModoOffline.h)
    botao(Botao_ModoOnline.x, Botao_ModoOnline.y, Botao_ModoOnline.w, Botao_ModoOnline.h)
  end
end

return menu