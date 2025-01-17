// Copyright (c) RoochNetwork
// SPDX-License-Identifier: Apache-2.0

// ** MUI Imports
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'

// ** Type Imports
import { Settings } from 'src/@core/context/settingsContext'

import { SupportChains } from '@roochnetwork/rooch-sdk-kit'
import Typography from '@mui/material/Typography'

interface Props {
  settings: Settings
}

const SwitchChainDropdown = (props: Props) => {
  return (
    <Button variant="text" size="small" disabled={true}>
      <Box sx={{ mr: 0, display: 'flex', flexDirection: 'column', textAlign: 'center' }}>
        <Typography sx={{ fontWeight: 500 }}>{'CHAIN-' + SupportChains[0]}</Typography>
      </Box>
    </Button>
  )
}

export default SwitchChainDropdown
