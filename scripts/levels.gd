extends RefCounted
class_name WardData

# Index is the mechanic contract used by the campaign controller.
# These are fictional records; they contain no real medication or dosage advice.
const WARDS: Array = [
	{
		"title": ["The Counter", "조제대"],
		"rule": ["Restore three fragments. The waiting shadow is slow here. Bring the records to the dispensing hatch.", "세 조각을 되찾으세요. 이곳의 그림자는 느립니다. 기록을 모아 조제 창구로 가져가세요."],
		"memory": ["The pharmacy closed ten years ago. Tonight, its bell rang. A receipt printed your name: ten prescriptions unfilled.", "이 약국은 십 년 전에 문을 닫았습니다. 오늘 밤 종이 울렸습니다. 영수증에는 당신의 이름과 미완성 처방전 열 장이 찍혀 있었습니다."],
		"patient": ["The Waiting One", "기다리는 자"]
	},
	{
		"title": ["Cold Storage", "냉장 보관실"],
		"rule": ["The power fails in this ward. Keep a path to a recharge station; your light is your shelter.", "이 구역은 전력이 불안정합니다. 충전소로 돌아갈 길을 기억하세요. 빛이 당신의 피난처입니다."],
		"memory": ["Every drawer held a name. The owner kept them in the cold, afraid that the world would forget them.", "서랍마다 이름이 하나씩 있었습니다. 주인은 세상이 그들을 잊을까 두려워 이름들을 차가운 곳에 보관했습니다."],
		"patient": ["The Cold Shadow", "차가운 그림자"]
	},
	{
		"title": ["Waiting Room", "대기실"],
		"rule": ["An alarm sounds every twelve seconds and calls the shadow. Move away from the ringing bell.", "십이 초마다 경보가 울려 그림자를 부릅니다. 종소리가 나는 곳에서 벗어나세요."],
		"memory": ["Ticket 041 was called every night. The chair stayed empty. Someone had removed its owner's name from the book.", "매일 밤 041번을 불렀습니다. 의자는 비어 있었습니다. 누군가 명부에서 그 의자 주인의 이름을 지웠습니다."],
		"patient": ["The Unanswered", "응답받지 못한 자"]
	},
	{
		"title": ["Spill Ward", "유출 병동"],
		"rule": ["Spilled residue burns through composure. Cross clean tiles and watch for the marked floor.", "유출된 잔여물이 침착함을 깎아 내립니다. 표시된 바닥을 피하고 깨끗한 길로 이동하세요."],
		"memory": ["A broken vial stained the floor. Beneath it was a list of people who had nowhere else to go.", "깨진 유리병이 바닥을 물들였습니다. 그 아래에는 갈 곳 없는 사람들의 명단이 있었습니다."],
		"patient": ["The Stained Shadow", "얼룩진 그림자"]
	},
	{
		"title": ["Two Empty Chairs", "빈 의자 두 개"],
		"rule": ["Two shadows share the ward. A light pulse can buy time; cabinets can break a pursuit.", "두 그림자가 이곳을 떠돕니다. 빛의 파동으로 시간을 벌고 캐비닛에 숨어 추격을 끊으세요."],
		"memory": ["Your sister's handwriting filled the margins: 'A person is more than a missing record.' She was the last pharmacist here.", "여백은 누나의 글씨로 가득했습니다. '기록 하나가 사라져도 사람의 존재까지 사라지는 건 아니야.' 그녀는 이곳의 마지막 약사였습니다."],
		"patient": ["The Forgotten Pair", "잊힌 두 그림자"]
	},
	{
		"title": ["Failing Filament", "꺼져 가는 필라멘트"],
		"rule": ["Unstable wiring drains your light faster. Recharge often and spend each pulse carefully.", "불안정한 전선 탓에 빛이 더 빨리 소모됩니다. 자주 충전하고 빛의 파동을 신중하게 쓰세요."],
		"memory": ["She kept the lamp on after the bills stopped being paid. 'If they return,' she wrote, 'someone must be here.'", "요금을 내지 못한 뒤에도 누나는 등을 켜 두었습니다. '그들이 돌아오면, 누군가는 여기 있어야 해.' 그녀는 그렇게 적었습니다."],
		"patient": ["The Fading Shadow", "희미해지는 그림자"]
	},
	{
		"title": ["The Long Hall", "긴 복도"],
		"rule": ["The shadow moves quickly through this ward. Plan a safe route between cabinets and recharge stations.", "이 구역의 그림자는 빠르게 움직입니다. 캐비닛과 충전소를 잇는 안전한 경로를 계획하세요."],
		"memory": ["The footsteps were never hunting her. They were following the only light left in the building.", "그 발소리는 누나를 사냥한 적이 없었습니다. 건물에 마지막으로 남은 빛을 따라왔을 뿐입니다."],
		"patient": ["The Hurrying Shadow", "서두르는 그림자"]
	},
	{
		"title": ["Blackwater Archive", "검은물 기록실"],
		"rule": ["Blackouts conceal spilled residue. Use your remaining light to read the floor before you move.", "정전이 유출된 잔여물을 감춥니다. 움직이기 전에 남은 빛으로 바닥을 살피세요."],
		"memory": ["The official archive called them lost cases. Your sister copied every name before the files were destroyed.", "공식 기록은 그들을 종결된 사례라 불렀습니다. 누나는 서류가 폐기되기 전에 모든 이름을 옮겨 적었습니다."],
		"patient": ["The Kept Names", "지켜 낸 이름들"]
	},
	{
		"title": ["Return to Sender", "반송된 편지"],
		"rule": ["Two shadows answer the alarm. Prepare a hiding place before the next bell rings.", "두 그림자가 경보에 반응합니다. 다음 종이 울리기 전에 숨을 곳을 확보하세요."],
		"memory": ["Her final letter was addressed to you: 'Do not cure the darkness. Give back what it is carrying.'", "누나의 마지막 편지는 당신에게 보내는 것이었습니다. '어둠을 치료하려 하지 마. 어둠이 품고 있는 것을 돌려줘.'"],
		"patient": ["The Returning Shadows", "돌아오는 그림자들"]
	},
	{
		"title": ["The Tenth Prescription", "열 번째 처방전"],
		"rule": ["Three shadows guard the final records. Restore all fragments, then choose what the pharmacy will remember.", "세 그림자가 마지막 기록을 지킵니다. 모든 조각을 되찾은 뒤 약국이 무엇을 기억할지 선택하세요."],
		"memory": ["No medicine was missing. Only names. The shadows carried the weight of being forgotten. The final prescription is yours to finish.", "사라진 것은 약이 아니라 이름이었습니다. 그림자들은 잊힌다는 무게를 짊어지고 있었습니다. 마지막 처방전을 완성할 사람은 당신입니다."],
		"patient": ["Those Still Waiting", "아직 기다리는 이들"]
	}
]
