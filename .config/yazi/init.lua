-- function Header:host()
-- 	return ui.Line({ "Teste 123" })
-- 	-- if ya.target_family() ~= "unix" then
-- 	-- 	return ui.Line({ ya.target_family() })
-- 	-- end
-- 	-- return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
-- end

-- function Header:render(area)
-- 	local chunks = self:layout(area)

-- 	-- local left = ui.Line({ self:cwd() })
-- 	local left = ui.Line({ self:host(), self:cwd() })
-- 	local right = ui.Line({ self:tabs() })
-- 	return {
-- 		ui.Paragraph(chunks[1], { left }),
-- 		ui.Paragraph(chunks[2], { right }):align(ui.Paragraph.RIGHT),
-- 	}
-- end
