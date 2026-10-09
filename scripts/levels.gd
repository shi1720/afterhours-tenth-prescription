extends RefCounted
class_name WardData

# Ten fictional pharmacy rooms. Array fields retain index zero compatibility.
# No medication instructions or real patient information.
const WARDS: Array = [
	{
		"title": [
			"The Counter"
		],
		"rule": [
			"Pulse near a sealed record, then press E and stay still to recover it. Each pulse costs 24 charge. Three names open the hatch."
		],
		"memory": [
			"The first receipt is dated ten years ago. Your sister left three names beneath the till and a note: \"If the town forgets, let this place remember.\" The printer has been waiting for someone to answer."
		],
		"patient": [
			"The One at the Counter"
		],
		"intro": "The receipt printer wakes without power. It prints the name on your badge, followed by one word: RETURN.",
		"exit": "The printer stops. A blank strip of paper keeps feeding into the dark.",
		"color": "9cbeb6"
	},
	{
		"title": [
			"Cold Storage"
		],
		"rule": [
			"Visibility falls in cycles. Remember the clean route back to the charger. Recovering a name leaves you still and exposed."
		],
		"memory": [
			"Your sister wrapped the names in waxed paper. \"Paper lasts longer in the cold,\" she wrote. One bundle contains a pressed flower, still blue. Someone trusted her to keep more than a record."
		],
		"patient": [
			"The Frost Keeper"
		],
		"intro": "The fridge motors turn over. Frost covers the bottles from the inside. Someone has cleared a handprint in the glass.",
		"exit": "A patch of frost melts into the shape of a hand. Nothing touches the glass.",
		"color": "91b7ce"
	},
	{
		"title": [
			"Number Forty-One"
		],
		"rule": [
			"The bell rings every twelve seconds and draws the shadow to you. Watch the countdown. Reach cover before you begin a recovery."
		],
		"memory": [
			"Ticket 041 belonged to a woman who arrived after closing. Your sister reopened the shutters. Later, when the office asked for a number instead of a name, she wrote both. The name survived here."
		],
		"patient": [
			"The Uncalled"
		],
		"intro": "The ticket display reads 041. Every chair faces it. The bell rings, but the number never changes.",
		"exit": "For one quiet second the display reads 042. Then the room goes dark.",
		"color": "d6c3a7"
	},
	{
		"title": [
			"The Broken Seal"
		],
		"rule": [
			"The spill pulses between dangerous and quiet phases. Use clean routes. Do not begin recovering a record on an active spill."
		],
		"memory": [
			"The pipe burst the winter the building closed. Your sister carried the records upstairs one box at a time. On the last box she wrote: \"A leak is not permission to lose a person.\""
		],
		"patient": [
			"The Waterline"
		],
		"intro": "A pipe drips into an empty tray. The water darkens every label it touches. Three envelopes remain above the tide.",
		"exit": "The pipe gives one final knock. The water keeps the reflection of your light.",
		"color": "a5c1ae"
	},
	{
		"title": [
			"Two Empty Chairs"
		],
		"rule": [
			"Two shadows cross this room. A pulse stops nearby pursuers, but its sound draws others. Break pursuit at a cabinet before recovering a name."
		],
		"memory": [
			"Two brothers used to wait for each other here. Your sister kept their records together after the town filed them apart. In the margin she drew two chairs, neither crossed out."
		],
		"patient": [
			"The Waiting Pair"
		],
		"intro": "Two chairs stand side by side. One has a folded coat on it. The other has the impression of someone who just stood up.",
		"exit": "The coat slips from the chair. Beneath it, the seat is warm.",
		"color": "c8a9b7"
	},
	{
		"title": [
			"The Last Filament"
		],
		"rule": [
			"Charge drains faster here. Pulses reveal names and buy only 2.6 seconds. Recharge before a long crossing, then leave before shadows arrive."
		],
		"memory": [
			"The unpaid bills are clipped behind the fuse box. Your sister sold the sign over the door to keep one lamp burning. \"They know where the light is,\" she wrote. \"That should still mean something.\""
		],
		"patient": [
			"The Wick"
		],
		"intro": "A fuse clicks behind the wall. In the brief light you see a handwritten sign: LEAVE THIS ONE ON.",
		"exit": "The fuse stops clicking. Somewhere behind the wall, a second lamp switches on.",
		"color": "b4aec9"
	},
	{
		"title": [
			"The Long Hall"
		],
		"rule": [
			"The pursuer here is fast. Choose your next cabinet before leaving cover. Quiet movement reduces how far your footsteps carry."
		],
		"memory": [
			"The phone log holds calls your sister never charged for. Directions home. A birthday remembered. A voice on an empty evening. The final entry says only: \"Stayed until they hung up.\""
		],
		"patient": [
			"The Caller"
		],
		"intro": "The phone rings at the far end. With every ring it sounds one doorway closer. The cord has been cut.",
		"exit": "The receiver lifts by itself. You hear someone say thank you before the line closes.",
		"color": "ccb59f"
	},
	{
		"title": [
			"Blackwater Archive"
		],
		"rule": [
			"Blackouts and active spills overlap. Learn the floor while you can see it. Keep enough charge to reveal the next record and stop a pursuit."
		],
		"memory": [
			"The town ordered the archive destroyed. Your sister copied thirty names before the fire reached the shelves. These pages are the copies. Every ordinary detail is in her handwriting: a street, a birthday, a place at a table."
		],
		"patient": [
			"The Ash Keeper"
		],
		"intro": "The cabinets smell of smoke. The surviving pages float face down in black water, as though the room cannot bear to read them.",
		"exit": "A charred page turns over. For a moment its handwriting looks newly wet.",
		"color": "92b6aa"
	},
	{
		"title": [
			"Letters Never Sent"
		],
		"rule": [
			"Two pursuers answer the twelve-second bell. A pulse can alert a distant shadow. Find cover before the countdown reaches zero."
		],
		"memory": [
			"Her last letter was for you. \"I know you could not come back,\" it begins. \"I kept your place anyway.\" Below it is a second line: \"When the light calls them, remember they have somewhere to go.\""
		],
		"patient": [
			"The Returning Pair"
		],
		"intro": "Unsent letters fill the sorting slots. Each envelope bears your old address. One has been opened from the inside.",
		"exit": "Every envelope turns toward the door. For once, none of them bears your name.",
		"color": "b1a2c2"
	},
	{
		"title": [
			"The Tenth Prescription"
		],
		"rule": [
			"Three shadows, the bell and the spill share the final room. Restore all three names. At the hatch, decide what the pharmacy keeps."
		],
		"memory": [
			"The final prescription has no medicine written on it. Your sister left a place for a witness. The names are whole again. The shadows wait by the window, facing the town that forgot them."
		],
		"patient": [
			"Those Still Waiting"
		],
		"intro": "Thirty spaces wait on the wall. You recognize your sister's handwriting in every label except the last. That space is yours to fill.",
		"exit": "The bell falls silent. On the other side of the shutters, morning begins.",
		"color": "dfc49f"
	}
]
