import { useBackend } from '../backend';
import { Button, Flex, Section } from '../components';
import { Window } from '../layouts';

export const MainframeRomUnit = (props) => {
  const { act, data } = useBackend();
  const {
    banks = [],
  } = data;
  return (
    <Window
      width={350}
      height={125}
      theme="retro"
      title="Mainframe ROM Unit">
      <Window.Content>
        <Flex>
          {banks.map((x, i) => (
            <Flex.Item
              textAlign="center"
              minWidth={7}
              key={i}>
              <Section>
                <div>
                  ${(0xFFFF - i * 256).toString(16).toUpperCase()}
                </div>
                <Button
                  mt={1}
                  mb={1}
                  content={x ? "Eject" : "Insert"}
                  color={x ? "bad" : "good"}
                  icon="eject"
                  onClick={() => act('', {
                    slot: i + 1,
                  })} />
                <div>
                  ${(0xFFFF - (i + 1) * 256).toString(16).toUpperCase()}
                </div>
              </Section>
            </Flex.Item>
          ))}
        </Flex>
      </Window.Content>
    </Window>
  );
};
