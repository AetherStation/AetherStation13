import { useBackend, useSharedState } from '../backend';
import { Button, Flex, NoticeBox, ProgressBar, Section, Tabs, TextArea } from '../components';
import { Window } from '../layouts';

export const ChemAssembler = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useSharedState('tab', 1);
  const slots = data.slots || [];
  const program_text = data.program || "";
  return (
    <Window
      width={320}
      height={450}>
      <Window.Content>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Status
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Programming
          </Tabs.Tab>
          <Button
            position="absolute"
            right="10px"
            color={data.running ? "green" : "red"}
            icon="power-off"
            mt="2px"
            mb="2px"
            onClick={() => act("run")} />
          <Button
            position="absolute"
            right="40px"
            color="green"
            icon="print"
            mt="2px"
            mb="2px"
            tooltip="Print manual"
            onClick={() => act("manual")} />
        </Tabs>
        {tab === 1 && (
          <Flex direction="column">
            <ProgressBar value={slots["H"]}><b>H</b>eater</ProgressBar>
            <Flex>
              <ProgressBar value={slots["I1"]}>I1</ProgressBar>
              <ProgressBar value={slots["A1"]}>A1</ProgressBar>
              <ProgressBar value={slots["B1"]}>B1</ProgressBar>
              <ProgressBar value={slots["C1"]}>C1</ProgressBar>
            </Flex>
            <Flex>
              <ProgressBar value={slots["I2"]}>I2</ProgressBar>
              <ProgressBar value={slots["A2"]}>A2</ProgressBar>
              <ProgressBar value={slots["B2"]}>B2</ProgressBar>
              <ProgressBar value={slots["C2"]}>C2</ProgressBar>
            </Flex>
            <Flex>
              <ProgressBar value={slots["I3"]}>I3</ProgressBar>
              <ProgressBar value={slots["A3"]}>A3</ProgressBar>
              <ProgressBar value={slots["B3"]}>B3</ProgressBar>
              <ProgressBar value={slots["C3"]}>C3</ProgressBar>
            </Flex>
            <ProgressBar value={slots["O"]}><b>O</b>utput</ProgressBar>
          </Flex>
        )}
        {tab === 2 && (
          <>
            {!!data.error && (
              <NoticeBox height={2} danger nowrap>
                {data.error}
              </NoticeBox>
            )}
            <Section>
              <TextArea fontFamily="monospace" fluid width="100%" height={data.error ? "298px" : "327px"} value={program_text}
                onChange={(e, value) => act("update_program", {
                  text: value,
                })} />
            </Section>
            <Button color="red" content="Clear" onClick={() => act("clear_program")} />
            <Button position="absolute" right="10px" color="green" content="Compile" onClick={() => act("compile_program")} />
          </>
        )}
      </Window.Content>
    </Window>
  );
};
