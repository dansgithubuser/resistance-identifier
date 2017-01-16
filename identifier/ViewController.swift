//
//  ViewController.swift
//  identifier
//
//  Created by Daniel on 1/15/17.
//
//

import UIKit

extension String {
	subscript(r: CountableClosedRange<Int>)->String {
		get {
			let startIndex=self.index(self.startIndex, offsetBy: r.lowerBound)
			let endIndex=self.index(startIndex, offsetBy: r.upperBound-r.lowerBound)
			return self[startIndex...endIndex]
		}
	}
}

extension Array {
	mutating func randomPop() -> Element {
		let i=Int(arc4random_uniform(UInt32(self.count)))
		let r=self[i]
		self.remove(at: i)
		return r
	}
	
	mutating func shuffle() {
        if count<=1 { return }
        for(firstUnshuffled, unshuffledCount) in zip(indices, stride(from: count, to: 1, by: -1)) {
            let d: IndexDistance=numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			if d==0 { continue }
            swap(&self[firstUnshuffled], &self[index(firstUnshuffled, offsetBy: d)])
        }
    }
}

class ViewController: UIViewController {
	@IBOutlet var players: Array<UITextField>?
	@IBOutlet var showKnowledges: Array<UIButton>?
	@IBOutlet var lastAssignment: UILabel?
	@IBOutlet var merlin: UISwitch?
	@IBOutlet var percival: UISwitch?
	@IBOutlet var mordred: UISwitch?
	@IBOutlet var morgana: UISwitch?
	@IBOutlet var oberon: UISwitch?
	@IBOutlet var assassin: UISwitch?
	var spies=[Int]()
	var playerMerlin=0
	var playerPercival=0
	var playerMordred=0
	var playerMorgana=0
	var playerOberon=0
	var playerAssassin=0
	let playersToSpies=[0, 0, 0, 0, 0, 2, 2, 3, 3, 3, 4]

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func assign(sender: UIButton) {
		let c=UIAlertController(
			title: "did you really",
			message: "want to assign?",
			preferredStyle: .alert
		)
		c.addAction(UIAlertAction(title: "yes", style: .default, handler: { (action: UIAlertAction!) in
			c.dismiss(animated: true, completion: nil)
			//assign
			var playing=0
			for i in self.players! { if !i.text!.isEmpty { playing+=1 } }
			if playing<5 { return }
			var players=[Int]()
			players+=0...(playing-1)
			if self.mordred!.isOn { self.playerMordred=players.randomPop() } else { self.playerMordred = -1 }
			if self.morgana!.isOn { self.playerMorgana=players.randomPop() } else { self.playerMorgana = -1 }
			if self.oberon!.isOn { self.playerOberon=players.randomPop() } else { self.playerOberon = -1 }
			if self.assassin!.isOn { self.playerAssassin=players.randomPop() } else { self.playerAssassin = -1 }
			self.spies.removeAll()
			while players.count>playing-self.playersToSpies[playing] {
				self.spies+=[players.randomPop()]
			}
			if self.merlin!.isOn { self.playerMerlin=players.randomPop() } else { self.playerMerlin = -1 }
			if self.percival!.isOn { self.playerPercival=players.randomPop() } else { self.playerPercival = -1 }
			//record
			let date=Date()
			let formatter=DateFormatter()
			formatter.dateFormat="HH:mm:ss"
			var s=formatter.string(from: date)
			let t=self.lastAssignment!.text!
			if t[0...7] == s { s+="*" }
			self.lastAssignment!.text=s
		}))
		c.addAction(UIAlertAction(title: "no", style: .default, handler: { (action: UIAlertAction!) in
			c.dismiss(animated: true, completion: nil)
		}))
		present(c, animated: true, completion: nil)
	}

	@IBAction func showKnowledge(sender: UIButton) {
		let i=showKnowledges!.index(of: sender)
		let c=UIAlertController(
			title: "did you really",
			message: "want to show "+players![i!].text!+"'s knowledge?",
			preferredStyle: .alert
		)
		c.addAction(UIAlertAction(title: "yes", style: .default, handler: { (action: UIAlertAction!) in
			c.dismiss(animated: true, completion: nil)
			func alert(title: String, message: String=""){
				let c=UIAlertController(
					title: title,
					message: message,
					preferredStyle: .alert
				)
				c.addAction(UIAlertAction(title: "ok", style: .default))
				self.present(c, animated: true, completion: nil)
			}
			func getSpies(merlin: Bool = false) -> String{
				var a=self.spies
				if !merlin { if self.playerMordred>=0 { a+=[self.playerMordred] } }
				if self.playerMorgana>=0 { a+=[self.playerMorgana] }
				if merlin { if self.playerOberon>=0 { a+=[self.playerOberon] } }
				if self.playerAssassin>=0 { a+=[self.playerAssassin] }
				a.shuffle()
				var r: String=""
				for i in a { r+=self.players![i].text!+" " }
				return r
			}
			func getMerlins() -> String{
				var a=[self.playerMerlin]
				if self.playerMorgana>=0 { a+=[self.playerMorgana] }
				a.shuffle()
				var r: String=""
				for i in a { r+=self.players![i].text!+" " }
				return r
			}
			if i==self.playerMerlin { alert(title: "you are merlin", message: "spies are: "+getSpies(merlin: true)) }
			else if i==self.playerPercival { alert(title: "you are percival", message: "merlins are: "+getMerlins()) }
			else if i==self.playerMordred { alert(title: "you are mordred", message: "spies are: "+getSpies()) }
			else if i==self.playerMorgana { alert(title: "you are morgana", message: "spies are: "+getSpies()) }
			else if i==self.playerOberon { alert(title: "you are oberon") }
			else if i==self.playerAssassin { alert(title: "you are the assassin", message: "spies are: "+getSpies()) }
			else if self.spies.contains(i!) { alert(title: "you are a spy", message: "spies are: "+getSpies()) }
			else { alert(title: "you are a resistance member") }
		}))
		c.addAction(UIAlertAction(title: "no", style: .default, handler: { (action: UIAlertAction!) in
			c.dismiss(animated: true, completion: nil)
		}))
		present(c, animated: true, completion: nil)
	}
	
	@IBAction func hideTheFrickinKeyboard() {
		view.endEditing(true)
	}
}
