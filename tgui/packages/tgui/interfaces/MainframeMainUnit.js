import { useBackend } from '../backend';
import { Box, Button, Flex, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const MainframeMainUnit = (props) => {
  const { act, data } = useBackend();
  const {
    on, pause, A, X, Y, SP, PC, status, opcode,
  } = data;
  return (
    <Window
      width={280}
      height={250}
      title="Mainframe Main Unit">
      <Window.Content>
        <Section
          title="Diagnostics"
          buttons={
            <>
              <Button
                color="caution"
                content="Reset"
                onClick={() => act('reset')} />
              <Button
                color="caution"
                icon="step-forward"
                onClick={() => act('step')} />
              <Button
                color={pause ? "bad" : "good"}
                icon={pause ? "pause" : "play"}
                onClick={() => act('pause')} />
              <Button
                color={on ? "good" : "bad"}
                icon="power-off"
                onClick={() => act('power')} />
            </>
          }>
          {!!on && (
            <Box fontFamily="monospace">
              A: {A.toUpperCase()} X: {X.toUpperCase()} Y: {Y.toUpperCase()}
              <br />SP: {SP.toUpperCase()} PC: {PC.toUpperCase()}<br />
              <Flex
                textAlign="center">
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 1 ? "good" : "bad"}>C
                </Flex.Item>
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 2 ? "good" : "bad"}>Z
                </Flex.Item>
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 4 ? "good" : "bad"}>I
                </Flex.Item>
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 8 ? "good" : "bad"}>D
                </Flex.Item>
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 16 ? "good" : "bad"}>B
                </Flex.Item>
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 64 ? "good" : "bad"}>V
                </Flex.Item>
                <Flex.Item
                  minHeight="16px" minWidth="16px"
                  style={{
                    'border-radius': '8px',
                  }}
                  backgroundColor={status & 128 ? "good" : "bad"}>N
                </Flex.Item>
              </Flex>
              {!!pause && (
                <>last opcode: {opcode.toUpperCase()}</>
              )}
            </Box>
          ) || (
            <NoticeBox>
              Power Off.
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
