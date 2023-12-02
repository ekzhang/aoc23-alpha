strings ← •Import "bqn-libs/strings.bqn"

ToNat ← 10⊸×⊸+˜´∘⌽-⟜'0'

# From the problem statement.
colors ← ⟨ "red", "green", "blue" ⟩
maxCubes ← ⟨ ⟨ "red", 12 ⟩, ⟨ "green", 13 ⟩, ⟨ "blue", 14 ⟩ ⟩

# Incredibly ugly way to implement a dictionary (there must be a better way…).
DictGet ← { 1⊑ ⊑ (𝕩≡⊑)¨ ⊸/ 𝕨 }

ParseLine ← {
  id‿desc ← ": " strings.Split 𝕩
  ⟨ ToNat 5 ↓ id, ToNat⌾⊑¨ " "⊸strings.Split¨ ∾ ", "⊸strings.Split¨ "; " strings.Split desc ⟩
}

Part1 ← {
  id‿plays ← ParseLine 𝕩
  id × ∧´ ⊑⊸≤⟜(maxCubes DictGet 1⊸⊑)¨ plays
}

Part2 ← {
  id‿plays ← ParseLine 𝕩
  ×´ { ⌈´ ⊑¨ 𝕩⊸≡⟜(1⊸⊑)¨ ⊸/ plays }¨ colors
}

lines ← •file.Lines "input.txt"
•Show +´ Part1¨ lines
•Show +´ Part2¨ lines

# Day 1, part 1 solution:
# +´ ((10×⊑)+(⊑⌽))¨ (∊⟜(↕10))⊸/¨ -⟜'0'
