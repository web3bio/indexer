INSERT INTO public.contracts (chain_id, address, name, owner)
VALUES
  (
    8453,
    lower('0x5289fE5daBC021D02FDDf23d4a4DF96F4E0F17EF'),
    'EFPAccountMetadata',
    lower('0xC9C3A4337a1bba75D0860A1A81f7B990dc607334')
  ),
  (
    8453,
    lower('0x0E688f5DCa4a0a4729946ACbC44C792341714e08'),
    'EFPListRegistry',
    lower('0xC9C3A4337a1bba75D0860A1A81f7B990dc607334')
  ),
  (
    8453,
    lower('0x41Aa48Ef3c0446b46a5b1cc6337FF3d3716E2A33'),
    'EFPListRecords',
    lower('0xC9C3A4337a1bba75D0860A1A81f7B990dc607334')
  ),
  (
    8453,
    lower('0xDb17Bfc64aBf7B7F080a49f0Bbbf799dDbb48Ce5'),
    'EFPListMinter',
    lower('0xC9C3A4337a1bba75D0860A1A81f7B990dc607334')
  ),
  (
    10,
    lower('0x4Ca00413d850DcFa3516E14d21DAE2772F2aCb85'),
    'EFPListRecords',
    lower('0xC9C3A4337a1bba75D0860A1A81f7B990dc607334')
  ),
  (
    1,
    lower('0x5289fE5daBC021D02FDDf23d4a4DF96F4E0F17EF'),
    'EFPListRecords',
    lower('0xC9C3A4337a1bba75D0860A1A81f7B990dc607334')
  )
ON CONFLICT (chain_id, address)
DO UPDATE SET
  name = EXCLUDED.name,
  owner = EXCLUDED.owner,
  updated_at = CURRENT_TIMESTAMP;