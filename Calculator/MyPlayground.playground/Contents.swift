//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
var str2 = "ground"

let n = str2.characters.count
let m = str.startIndex

let range = str.index(str.endIndex, offsetBy: -str2.characters.count)..<str.endIndex
str.removeSubrange(range)

var yy = [1,2,3,4]

yy.dropLast()


