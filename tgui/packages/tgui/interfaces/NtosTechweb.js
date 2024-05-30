import { useBackend } from '../backend';
import { createLogger } from '../logging';
import { AppTechweb } from './Techweb.js';

const logger = createLogger('backend');

export const NtosTechweb = (props) => {
  const { config, data, act } = useBackend();
  logger.log(config.AppTechweb);
  return (
    <AppTechweb />
  );
};
