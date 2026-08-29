`candidate-pairs.csv`: 

curated pair-sets, pre-tokenisation testing; 

pairs are annotated for origin e.g. from Jones 2002 study; and whether canonical / low-frequency / in WordNet; also for part-of-speech;

---

`selected-pairs.csv`: 

candidate pairs that have been checked for tokenisation; some additional WordNet info added;

---

`selected-pairs-core-only.csv`: 

excludes WordNet-only pairs; just used when de-duping WordNet pairs from the original Nguyen et al. set

---

`cxn-plus-pairs.csv`: 

the result of running mask tests for all constructions and all pairs

---

`cxn-plus-pairs-alike-form-comparison.csv`: 

records results of mask tests for the alike construction under 4 different mask variations: 
`, X and <mask> alike` (the default)
` X and <mask> alike` (with leading space) 
`X and <mask> alike` (no comma / no leading space / X lowercased) 
`X and <mask> alike` (no comma / no leading space / X with initial capitalistion) 
used for testing the degree to which reciprocity result agree across different configurations with and without a leading comma

---
