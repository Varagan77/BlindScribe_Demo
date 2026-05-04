local Cfg = require("config.settings")

local ITEMS = {
	{ id = "wrath_spawn",   name = "Hex Ward",    category = "Wrath",    desc = "Spawns a monster tile nearby", cost = 4, icon = "W" },
	{ id = "wrath_curse",   name = "Dark Sigil",  category = "Wrath",    desc = "Doubles next monster damage",  cost = 6, icon = "W" },
	{ id = "spiritus_heal", name = "Salve",        category = "Spiritus", desc = "Restore 3 HP",                 cost = 3, icon = "S" },
	{ id = "spiritus_revive",name = "Ember Flask", category = "Spiritus", desc = "Restore 6 HP",                 cost = 5, icon = "S" },
	{ id = "kinesis_step",  name = "Swift Dust",   category = "Kinesis",  desc = "+3 move points",               cost = 3, icon = "K" },
	{ id = "kinesis_dash",  name = "Gale Rune",    category = "Kinesis",  desc = "+6 move points",               cost = 5, icon = "K" },
}

local CAT_COL = {
	Wrath    = { 1.00, 0.30, 0.30 },
	Spiritus = { 0.35, 0.85, 0.75 },
	Kinesis  = { 0.70, 0.55, 1.00 },
}

local C = {
	bg      = { 0.04, 0.04, 0.05 },
	panel   = { 0.08, 0.08, 0.10 },
	border  = { 0.25, 0.25, 0.30 },
	text    = { 0.85, 0.85, 0.85 },
	label   = { 0.45, 0.45, 0.55 },
	gold    = { 1.00, 0.85, 0.25 },
	sel     = { 0.16, 0.18, 0.22 },
	accent  = { 0.35, 0.85, 0.75 },
	danger  = { 1.00, 0.30, 0.30 },
	btnBuy  = { 0.20, 0.60, 0.40 },
}

local shop = {
	open       = false,
	cart       = {},
	notif      = nil,
	notifTimer = 0,
}

local function setC(t, a)
	love.graphics.setColor(t[1], t[2], t[3], a or 1)
end

local function cartTotal()
	local t = 0
	for _, e in ipairs(shop.cart) do t = t + e.item.cost * e.qty end
	return t
end

local function cartCount()
	local n = 0
	for _, e in ipairs(shop.cart) do n = n + e.qty end
	return n
end

local function freeSlots()
	local used = 0
	for i = 1, 12 do if player.inventory[i] ~= nil then used = used + 1 end end
	return 12 - used
end

local function cartEntryFor(item)
	for _, e in ipairs(shop.cart) do
		if e.item.id == item.id then return e end
	end
	return nil
end

local function addToCart(item)
	if cartCount() >= freeSlots() then
		shop.notif      = { msg = "No inventory space!", col = C.danger }
		shop.notifTimer = 2.0
		return
	end
	if cartTotal() + item.cost > player.gold then
		shop.notif      = { msg = "Not enough gold!", col = C.danger }
		shop.notifTimer = 2.0
		return
	end
	local e = cartEntryFor(item)
	if e then e.qty = e.qty + 1
	else shop.cart[#shop.cart + 1] = { item = item, qty = 1 } end
end

local function removeFromCart(item)
	for i, e in ipairs(shop.cart) do
		if e.item.id == item.id then
			e.qty = e.qty - 1
			if e.qty <= 0 then table.remove(shop.cart, i) end
			return
		end
	end
end

local function checkout()
	if cartCount() == 0 then
		shop.notif      = { msg = "Cart is empty.", col = C.label }
		shop.notifTimer = 1.5
		return
	end
	if cartTotal() > player.gold then
		shop.notif      = { msg = "Not enough gold!", col = C.danger }
		shop.notifTimer = 2.0
		return
	end
	if cartCount() > freeSlots() then
		shop.notif      = { msg = "Not enough inventory space!", col = C.danger }
		shop.notifTimer = 2.0
		return
	end

	player.gold = player.gold - cartTotal()

	for _, entry in ipairs(shop.cart) do
		for _ = 1, entry.qty do
			for i = 1, 12 do
				if player.inventory[i] == nil then
					player.inventory[i] = entry.item
					break
				end
			end
		end
	end

	local n = cartCount()
	hud_log("Purchased " .. n .. " item(s)!")
	shop.cart       = {}
	shop.notif      = { msg = "Purchase complete!", col = C.accent }
	shop.notifTimer = 2.0
end

function shop_open()
	shop.open  = true
	shop.cart  = {}
	shop.notif = nil
end

function shop_close()
	shop.open = false
	shop.cart = {}
end

function shop_isOpen()
	return shop.open
end

function shop_update(dt)
	if shop.notifTimer > 0 then shop.notifTimer = shop.notifTimer - dt end
end

function shop_keypressed(key)
	if not shop.open then return end
	if key == "escape" then shop_close() end
end

function shop_layout()
	local sw  = love.graphics.getWidth()
	local sh  = love.graphics.getHeight()
	local W   = math.min(580, sw - 40)
	local H   = math.min(500, sh - 40)
	local ox  = math.floor((sw - W) / 2)
	local oy  = math.floor((sh - H) / 2)
	local pad = 14
	local leftW  = math.floor(W * 0.60)
	local rightW = W - leftW - pad * 3
	local rowH   = 58
	local listX  = ox + pad
	local listY  = oy + 62
	local cartX  = ox + leftW + pad * 2
	local cartY  = listY
	local cartH  = H - (cartY - oy) - pad
	local buyX   = cartX + math.floor(rightW * 0.10)
	local buyW   = math.floor(rightW * 0.80)
	local buyY   = oy + H - 50
	local buyH   = 32
	return {
		W=W, H=H, ox=ox, oy=oy, pad=pad,
		leftW=leftW, rightW=rightW,
		rowH=rowH, listX=listX, listY=listY,
		cartX=cartX, cartY=cartY, cartH=cartH,
		buyX=buyX, buyW=buyW, buyY=buyY, buyH=buyH,
	}
end

function shop_mousepressed(mx, my, btn)
	if not shop.open or btn ~= 1 then return end
	local L = shop_layout()

	for i, item in ipairs(ITEMS) do
		local ry     = L.listY + (i - 1) * L.rowH
		local minusX = L.listX + L.leftW - 58
		local plusX  = L.listX + L.leftW - 30
		local btnY   = ry + 18

		if mx >= plusX and mx <= plusX + 22 and my >= btnY and my <= btnY + 22 then
			addToCart(item)
			return
		end
		if mx >= minusX and mx <= minusX + 22 and my >= btnY and my <= btnY + 22 then
			removeFromCart(item)
			return
		end
	end

	if mx >= L.buyX and mx <= L.buyX + L.buyW and my >= L.buyY and my <= L.buyY + L.buyH then
		checkout()
	end
end

function shop_draw()
	if not shop.open then return end
	local L  = shop_layout()
	local sw = love.graphics.getWidth()
	local sh = love.graphics.getHeight()

	setC(C.bg, 0.90)
	love.graphics.rectangle("fill", 0, 0, sw, sh)

	setC(C.panel)
	love.graphics.rectangle("fill", L.ox, L.oy, L.W, L.H, 10, 10)
	setC(C.border)
	love.graphics.rectangle("line", L.ox, L.oy, L.W, L.H, 10, 10)

	setC(C.accent)
	love.graphics.setFont(love.graphics.newFont(20))
	love.graphics.printf("SHOP", L.ox, L.oy + L.pad, L.W, "center")

	setC(C.gold)
	love.graphics.setFont(love.graphics.newFont(12))
	love.graphics.printf("Gold: " .. player.gold, L.ox, L.oy + L.pad + 26, L.W - L.pad, "right")

	setC(C.border)
	love.graphics.line(L.ox + L.pad, L.oy + 56, L.ox + L.W - L.pad, L.oy + 56)

	for i, item in ipairs(ITEMS) do
		local ry  = L.listY + (i - 1) * L.rowH
		local col = CAT_COL[item.category]
		local ce  = cartEntryFor(item)
		local qty = ce and ce.qty or 0

		if qty > 0 then
			setC(C.sel)
			love.graphics.rectangle("fill", L.listX, ry + 2, L.leftW - L.pad, L.rowH - 6, 5, 5)
			setC(col, 0.5)
			love.graphics.rectangle("line", L.listX, ry + 2, L.leftW - L.pad, L.rowH - 6, 5, 5)
		end

		local iconSz = 28
		setC(col, 0.22)
		love.graphics.rectangle("fill", L.listX + 6, ry + (L.rowH - iconSz) / 2, iconSz, iconSz, 4, 4)
		setC(col)
		love.graphics.setFont(love.graphics.newFont(13))
		love.graphics.printf(item.icon, L.listX + 6, ry + (L.rowH - iconSz) / 2 + 7, iconSz, "center")

		local tx = L.listX + iconSz + 14
		setC(C.text)
		love.graphics.setFont(love.graphics.newFont(13))
		love.graphics.print(item.name, tx, ry + 8)
		setC(C.label)
		love.graphics.setFont(love.graphics.newFont(10))
		love.graphics.print(item.desc, tx, ry + 26)
		setC(col)
		love.graphics.print("[" .. item.category .. "]", tx, ry + 40)

		setC(C.gold)
		love.graphics.setFont(love.graphics.newFont(12))
		love.graphics.print(item.cost .. "g", L.listX + L.leftW - 80, ry + 8)

		local minusX = L.listX + L.leftW - 58
		local plusX  = L.listX + L.leftW - 30
		local btnY   = ry + 18

		setC(C.sel)
		love.graphics.rectangle("fill", minusX, btnY, 22, 22, 3, 3)
		setC(C.border)
		love.graphics.rectangle("line", minusX, btnY, 22, 22, 3, 3)
		setC(qty > 0 and C.danger or C.label)
		love.graphics.setFont(love.graphics.newFont(14))
		love.graphics.printf("-", minusX, btnY + 3, 22, "center")

		setC(C.sel)
		love.graphics.rectangle("fill", plusX, btnY, 22, 22, 3, 3)
		setC(C.border)
		love.graphics.rectangle("line", plusX, btnY, 22, 22, 3, 3)
		setC(C.accent)
		love.graphics.setFont(love.graphics.newFont(14))
		love.graphics.printf("+", plusX, btnY + 3, 22, "center")

		if qty > 0 then
			setC(C.text)
			love.graphics.setFont(love.graphics.newFont(11))
			love.graphics.printf("x" .. qty, minusX, btnY + 4, 22 + 8 + 22, "center")
		end
	end

	setC({ 0.06, 0.06, 0.08 })
	love.graphics.rectangle("fill", L.cartX, L.cartY, L.rightW, L.cartH, 6, 6)
	setC(C.border)
	love.graphics.rectangle("line", L.cartX, L.cartY, L.rightW, L.cartH, 6, 6)

	setC(C.accent)
	love.graphics.setFont(love.graphics.newFont(11))
	love.graphics.printf("CART", L.cartX, L.cartY + 8, L.rightW, "center")

	local cy2 = L.cartY + 26
	if #shop.cart == 0 then
		setC(C.label)
		love.graphics.setFont(love.graphics.newFont(10))
		love.graphics.printf("empty", L.cartX, cy2 + 10, L.rightW, "center")
	else
		for _, entry in ipairs(shop.cart) do
			local col = CAT_COL[entry.item.category]
			setC(col)
			love.graphics.setFont(love.graphics.newFont(10))
			love.graphics.printf(entry.item.name, L.cartX + 4, cy2, L.rightW - 8, "left")
			setC(C.gold)
			love.graphics.printf("x" .. entry.qty .. "  " .. entry.item.cost * entry.qty .. "g", L.cartX + 4, cy2, L.rightW - 8, "right")
			cy2 = cy2 + 16
		end

		setC(C.border)
		love.graphics.line(L.cartX + 6, cy2 + 2, L.cartX + L.rightW - 6, cy2 + 2)
		cy2 = cy2 + 8

		setC(C.gold)
		love.graphics.setFont(love.graphics.newFont(11))
		love.graphics.printf("Total: " .. cartTotal() .. "g", L.cartX + 4, cy2, L.rightW - 8, "right")
	end

	local canBuy = #shop.cart > 0 and cartTotal() <= player.gold and cartCount() <= freeSlots()
	setC(canBuy and C.btnBuy or C.sel)
	love.graphics.rectangle("fill", L.buyX, L.buyY, L.buyW, L.buyH, 5, 5)
	setC(canBuy and C.accent or C.border)
	love.graphics.rectangle("line", L.buyX, L.buyY, L.buyW, L.buyH, 5, 5)
	setC(canBuy and C.text or C.label)
	love.graphics.setFont(love.graphics.newFont(13))
	love.graphics.printf("BUY ALL", L.buyX, L.buyY + 8, L.buyW, "center")

	if shop.notifTimer > 0 then
		local a = math.min(shop.notifTimer, 1)
		setC(shop.notif.col, a)
		love.graphics.setFont(love.graphics.newFont(11))
		love.graphics.printf(shop.notif.msg, L.ox, L.oy + L.H - 68, L.W, "center")
	end

	setC(C.label)
	love.graphics.setFont(love.graphics.newFont(10))
	love.graphics.printf("[E / ESC] Close", L.ox, L.oy + L.H - 18, L.W, "center")

	love.graphics.setColor(1, 1, 1)
end