---
name: context-create-diagnose-resolution
description: Troubleshoot rejected submissions, stuck processing, or unexpected market resolutions
---

# Diagnose Resolution

Troubleshoot markets that were rejected during submission, stuck in processing, or resolved unexpectedly.

## When to Use

A market submission was rejected, is taking too long to process, or a live market resolved in a way that seems wrong.

## Submission Rejected

The oracle reviewed the draft and refused to create the market.

1. **Check the response** — `submission.refuseToResolve` will be true. Look at `submission.rejectionReasons` for specific issues.
2. **Common rejection reasons:**
   - **Ambiguous criteria** — the oracle can't determine a clear YES/NO outcome from your criteria. Make them more specific.
   - **No verifiable sources** — the oracle has no way to find evidence. Add specific X handles or enable `web_enabled`.
   - **Too subjective without definition** — "Will reception be positive?" needs a measurable definition of "positive."
   - **Duplicate market** — a similar market already exists. Check `submission.similarMarkets` for existing alternatives.
3. **Fix and resubmit** — adjust the criteria, sources, or question and submit again.

## Submission Stuck in Processing

The submission hasn't completed after 90+ seconds.

1. **Check status** — `ctx.questions.getSubmission(submissionId)` or `context questions status <submissionId>`
2. **Possible states:**
   - `"processing"` — still being evaluated. Normal processing is 30–90 seconds. Wait up to 3 minutes before retrying.
   - `"failed"` — the oracle encountered an error. Try rephrasing the question.
   - `"completed"` — done. Check `submission.questions` for the generated market.
3. **If truly stuck** — submit a new draft rather than waiting indefinitely. The old submission will eventually timeout.

## Market Resolved Incorrectly

A live market resolved to an outcome that seems wrong.

1. **Review the resolution criteria** — `context_get_market` returns the full criteria. Read them literally — the oracle follows the criteria as written, not as intended.
2. **Check the claim type:**
   - **Event-by-deadline / threshold** — could have resolved YES early because the condition was met at some point, even if it later reversed.
   - **Period-gated** — can only resolve at the end of the period. If it resolved early, the criteria may have been ambiguous about the claim type.
3. **Check evidence sources:**
   - For `social_only` — did the specified X accounts post about the outcome? If not, the oracle may have lacked evidence.
   - For `web_enabled` — did authoritative sources report the outcome? Web evidence overrides social media.
4. **Common causes of "wrong" resolutions:**
   - Criteria were technically correct but didn't match the creator's intent
   - The event happened but wasn't reported by the specified sources
   - Edge case not covered in criteria (cancellation, postponement, partial outcome)

## Gotchas

- **The oracle follows criteria literally.** If your criteria say "announced on X/Twitter" and the announcement was on a website, the oracle resolves NO for `social_only` markets.
- **`web_enabled` evidence overrides social media.** If X posts say one thing but an authoritative source says another, the web source wins.
- **Rejected ≠ failed.** Rejection means the oracle reviewed and declined. Failure means a processing error. Different fix approaches.
- **Similar markets are surfaced on rejection.** Check `submission.similarMarkets` — your market may already exist.

## Verification

- After fixing a rejection: resubmission completes with `status: "completed"` and `refuseToResolve: false`.
- After investigating a resolution: understand why the oracle resolved as it did based on the criteria and available evidence.

## See Also

- [Resolution Criteria Guide](../references/resolution-criteria.md) — How to write unambiguous criteria
- [Agent Submit API](../references/agent-submit-api.md) — Response fields, error codes
