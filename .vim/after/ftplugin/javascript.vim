" Disable tsserver for ALE, it doesn't support flow typing, we only need tsserver for YCM semantic completion
let b:ale_linters_ignore = ['tsserver']
