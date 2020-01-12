//
//  LetterClassification.swift
//  Third Eye
//
//  Created by Joshua Colley on 13/04/2018.
//  Copyright © 2018 Joshua Colley. All rights reserved.
//

import Foundation

enum Letter: String, CustomStringConvertible {
    case A = "cap a"
    case B = "cap b"
    case C = "cap c"
    case D = "cap d"
    case E = "cap e"
    case F = "cap f"
    case G = "cap g"
    case H = "cap h"
    case I = "cap i"
    case J = "cap j"
    case K = "cap k"
    case L = "cap l"
    case M = "cap m"
    case N = "cap n"
    case O = "cap o"
    case P = "cap p"
    case Q = "cap q"
    case R = "cap r"
    case S = "cap s"
    case T = "cap t"
    case U = "cap u"
    case V = "cap v"
    case W = "cap w"
    case X = "cap x"
    case Y = "cap y"
    case Z = "cap z"
    
    var description: String {
        switch self {
        case .A: return "A"
        case .B: return "B"
        case .C: return "C"
        case .D: return "D"
        case .E: return "E"
        case .F: return "F"
        case .G: return "G"
        case .H: return "H"
        case .I: return "I"
        case .J: return "J"
        case .K: return "K"
        case .L: return "L"
        case .M: return "M"
        case .N: return "N"
        case .O: return "O"
        case .P: return "P"
        case .Q: return "Q"
        case .R: return "R"
        case .S: return "S"
        case .T: return "T"
        case .U: return "U"
        case .V: return "V"
        case .W: return "W"
        case .X: return "X"
        case .Y: return "Y"
        case .Z: return "Z"
        }
    }
}
