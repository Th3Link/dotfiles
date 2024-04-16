--- @class config.TSUtils
local TSUtils = {}

--- @param type string the type of ancestor to get
--- @param node? TSNode the node to get the parent of
--- @return nil|TSNode
--- @see TSNode.type
function TSUtils.get_next_ancestor(type, node)
	local section

	do
		local current_node = node or vim.treesitter.get_node()
		while current_node ~= nil and section == nil do
			if current_node:type() == type then
				section = current_node
				break
			end

			current_node = current_node:parent()
		end
	end

	return section
end

--- @alias config.TSUtils.get_sibling.direction 'next'|'previous'

--- @param node TSNode the node to get the sibling of
--- @param direction config.TSUtils.get_sibling.direction the
--- @return nil|TSNode
function TSUtils.get_sibling(node, direction)
	local parent = node:parent()
	if parent == nil then
		return vim.notify('Cannot get sibling because node has no parent', vim.log.levels.ERROR)
	end

	local found_current_section = false
	local next, previous --- @type nil|TSNode, nil|TSNode
	local node_id = node:id()
	local node_type = node:type()

	for child in parent:iter_children() do
		if child:type() == node_type then
			if found_current_section then
				next = child
				break
			end

			if child:id() == node_id then
				found_current_section = true
			else
				previous = child
			end
		end
	end

	if next ~= nil and direction == 'next' then
		return next
	elseif previous ~= nil and direction == 'previous' then
		return previous
	end
end

--- Place the cursor on a sibling
--- @param type string
--- @param direction config.TSUtils.get_sibling.direction
--- @param start_node? TSNode
--- @see config.TSUtils.get_sibling
--- @see config.TSUtils.get_next_ancestor
function TSUtils.goto_sibling(type, direction, start_node)
	local ancestor = TSUtils.get_next_ancestor(type, start_node)
	if ancestor == nil then
		return vim.notify('Cursor is not currently within a ' .. type, vim.log.levels.INFO)
	end

	local sibling =  TSUtils.get_sibling(ancestor, direction)
	if sibling == nil then
		return vim.notify('No ' .. direction .. ' sibling ' .. type, vim.log.levels.INFO)
	end

	TSUtils.set_cursor_on_node(sibling)
end

--- @param node TSNode
function TSUtils.set_cursor_on_node(node)
	local row, column = node:range()
	vim.api.nvim_win_set_cursor(0, {row + 1, column})
end

return TSUtils
