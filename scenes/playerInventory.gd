extends CharacterBody2D

var items=[]
func addToInventory(item):
	items.insert(0,item)
	print(items[0])
