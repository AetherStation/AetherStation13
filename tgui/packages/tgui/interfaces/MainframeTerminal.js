import { useBackend } from '../backend';
import { Section, Input } from '../components';
import { Window } from '../layouts';

export const MainframeTerminal = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    text = [],
    queue_length = 0,
  } = data;
  return (
    <Window
      width={610}
      height={405}
      title="Mainframe Terminal"
      theme="hackerman">
      <Window.Content
        fontFamily="monospace">
        <Section
          height={25}
          width={50}>
          {text.map((x, i) => {
            return (<span key={i}>{x}<br /></span>);
          }) }
        </Section>
        <Input
          width={50}
          onChange={(e, value) => act('send', {
            data: value,
          })} />
        <Section>
          Q:{queue_length}/256
        </Section>
      </Window.Content>
    </Window>
  );
};
