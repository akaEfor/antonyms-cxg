from transformers import RobertaTokenizer, RobertaModel
from transformers import AutoTokenizer, AutoModelForMaskedLM
from transformers import pipeline

import csv

PLM = 'roberta-large'
HOME_DIR = "."  # assumes home dir is antonyms_cxg root dir, from which jupyter notebook is run; could put an absolute path here;
DFLT_NUM_MASK_RESULTS = 5

def initTokeniser():

    return AutoTokenizer.from_pretrained(PLM, use_fast=True)

def initUnmasker(num_mask_results=DFLT_NUM_MASK_RESULTS):
    
    model = AutoModelForMaskedLM.from_pretrained(PLM)
    unmasker = pipeline('fill-mask', model=PLM, top_k=num_mask_results)
    tokeniser = AutoTokenizer.from_pretrained(PLM, use_fast=True)

    return (unmasker, model, tokeniser)
