from transformers import RobertaTokenizer, RobertaModel
from transformers import AutoTokenizer, AutoModelForMaskedLM
from transformers import pipeline

import warnings
import torch
import torch.nn.functional as F
from torch import Tensor

def dispMask(resLabel, res):
    for i, result in enumerate(res):
        print(f"{resLabel}({i+1}) {result['sequence']} [ masked token:{result['token_str']} ] (Score: {result['score']:.8f})")

def dispAllMasks(results):
    # if the first results element is itself a list, then we have a list of lists => results for multiple masks
    if not(isinstance(results[0], list)):
        dispMask("", results)
    else:
        for i in range(0, len(results)):
            dispMask("Mask " + str(i+1) + ":", results[i])

# fill in a masked template, look for prob of specific tokens: targetWord can be an array e.g. ["Ġbad","ĠBad","bad","Bad"]
# the Ġ character indicates a leading space
def probForSpecificToken(unmasker, maskTemplate, targetWord):
    res=unmasker(maskTemplate, targets=targetWord)
    #dispMask("", res)
    return res[0]['score']


def getMaskedLogits(model, tokeniser, maskTemplate, maskIndexToReturn):

    inputSeq = tokeniser.encode(maskTemplate, return_tensors='pt')
    maskIndex = torch.where(inputSeq == tokeniser.mask_token_id)[1] # we only want the the 2nd dimension
    #print(f"maskTemplate: {maskTemplate}; maskIndex is: {maskIndex}")
    tokenLogits = model(inputSeq).logits
    if (maskIndexToReturn == -1):
        return tokenLogits[0, maskIndex, :]
    else: 
        tensorIdx = torch.tensor([maskIndexToReturn])
        return tokenLogits[0, tensorIdx, :]

    return maskedLogits

def top5FromLogits(maskedLogits, maskTemplate):
    
    #probs = torch.nn.functional.softmax(maskedLogits, dim=-1)
    probs = F.softmax(maskedLogits, dim=-1)

    top5 = torch.topk(maskedLogits, 5, dim=1)
    top5ids = top5.indices[0].tolist()
    top5vals = top5.values[0].tolist()

    idx = 0
    for tokenId in top5ids:
        print(maskTemplate.replace(tokeniser.mask_token, tokeniser.decode([tokenId])))
        print(f"token index: {tokenId}")
        print(f"logit val: {top5vals[idx]}")
        idx = idx + 1
        print(f"prob: {probs[0][tokenId]}")


# Note: the following jensen_shannon_divergence computation taken from: 
# Rozner, J., Weissweiler, L., Mahowald, K., & Shain, C. (2025). Constructions are Revealed in Word Distributions 
# Proceedings of the 2025 Conference on Empirical Methods in Natural Language Processing, Suzhou, China. 
# https://doi.org/10.18653/v1/2025.emnlp-main.108
# https://github.com/jsrozner/cxs_are_revealed

def _kl_div_test(d1, d2):
    all_vals = d1 * torch.log(d1/d2)
    return all_vals.sum()
    
def _jensen_shannon_divergence_test(p: torch.Tensor, q: torch.Tensor) -> torch.Tensor:
    """
    Computes the Jensen-Shannon Divergence between two probability distributions.

    Args:
        p,q unidimensional logits

    Returns:
        torch.Tensor: Scalar tensor representing the JSD between p and q.
    """
    p = torch.softmax(p, dim=-1)
    q = torch.softmax(q, dim=-1)

    # Compute the midpoint distribution
    m = (p + q)/2

    res = 0.5 * (_kl_div_test(p, m) + _kl_div_test(q, m))
    return res

def jensen_shannon_divergence(
        p: torch.Tensor,
        q: torch.Tensor,
        check_values = False
) -> float:
    """
    Computes the Jensen-Shannon Divergence between two probability distributions.
    - this uses natural log based on our test

    Args:
        p,q unidimensional logits

    Returns:
        torch.Tensor: Scalar tensor representing the JSD between p and q.
    """
    # our reduction for kl_div requires sum, rather than mean
    assert len(p.shape) == len(q.shape) == 1

    p_log = F.log_softmax(p, dim=-1)
    q_log = F.log_softmax(q, dim=-1)

    # Compute the midpoint distribution in log-space
    m_log = torch.log(0.5 * (p_log.exp() + q_log.exp()))

    # Compute KL divergences
    # note that we needed reduction sum; this will not work for batches
    kl_pm = F.kl_div(m_log, p_log, log_target=True, reduction='sum')
    kl_qm = F.kl_div(m_log, q_log, log_target=True, reduction='sum')

    # Compute Jensen-Shannon Divergence
    jsd = 0.5 * (kl_pm + kl_qm)

    if check_values:
        test_val = _jensen_shannon_divergence_test(p, q)
        assert torch.allclose(test_val, jsd, atol=1e-5), f"{test_val.item()} != {jsd.item()}"

    return jsd.item()
