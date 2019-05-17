//Solution goes in Sources

import Foundation

class Matrix {
  var rows = [[Int]]()
  var columns = [[Int]]()

  init(_ input: String) {

    let inputs = input.split(separator: "\n")

    for input in inputs {
      let row = input.split(separator: " ").map({ Int($0)! })

      self.rows.append(row)

      for (i, col) in row.enumerated() {
        if self.columns.count == i { self.columns.append([]) }
        self.columns[i].append(col)
      }
    }
  }
}