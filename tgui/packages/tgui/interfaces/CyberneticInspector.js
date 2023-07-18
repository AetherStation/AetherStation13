import { toFixed } from 'common/math';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, Flex, LabeledList, ProgressBar, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';


export const CyberneticInspector = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    no_patient,
    patient,
    organs = [],
    bodyparts = [],
  } = data;
  return (
    <Window
      width={600}
      height={800}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 1}
            onClick={() => setTab(1)}>
            Bodyparts
          </Tabs.Tab>
          <Tabs.Tab
            icon="list"
            lineHeight="23px"
            selected={tab === 2}
            onClick={() => setTab(2)}>
            Organs
          </Tabs.Tab>
        </Tabs>
        <Section title="Patient Data">
          <Box><b>name: </b>{patient.name}</Box>
          <Box><b>neural overload progress: </b>{
            (patient.total_neural_stress/1280)*100
          }%
          </Box>
          <Box><b>passive neural load: </b>{
            (patient.total_neural_stress/1280)*100
          }%
          </Box>
        </Section>
        <Section title="Cybernetic Inspection">
          {no_patient===0 ? (
            tab===1 ? (
              <Flex direction="column">
                {bodyparts.map(bp => (
                  <Flex key={bp.name} direction="row" style={{ 'padding': "8px 8px 8px 8px" }}>
                    <Box
                      as="img"
                      src={`data:image/jpeg;base64,${bp.icon}`}
                      height="64px"
                      width="64px"
                      style={{
                        "-ms-interpolation-mode": "nearest-neighbor",
                        "vertical-align": "middle",
                      }}
                    />
                    <Flex direction="column">
                      <Box><b>name: </b>{bp.name} </Box>
                      <Box><b>origin: </b>{
                        bp.organic===1?(<>organic</>):(<>robotic</>)
                      }
                      </Box>
                    </Flex>
                  </Flex>
                ))}
              </Flex>
            ) : (
              <Flex direction="column">
                {organs.map(o => (
                  o.syndicate===0?(
                    <Flex direction="row" style={{ 'padding': "8px 8px 8px 8px" }}>
                      <Flex direction="column">
                        <Box
                          as="img"
                          src={`data:image/jpeg;base64,${o.icon}`}
                          height="64px"
                          width="64px"
                          style={{
                            "-ms-interpolation-mode": "nearest-neighbor",
                            "vertical-align": "middle",
                          }}
                        />
                      </Flex>
                      <Flex direction="column">
                        <Box><b>name: </b>{o.name} </Box>
                        <Box><b>desc: </b>{o.desc} </Box>
                        <Box><b>neural strain: </b>{o.cost} </Box>
                        <Box><b>organ type: </b>{o.class} </Box>
                      </Flex>
                    </Flex>
                  ):(<Box />)))}
              </Flex>
            )
          ) : (
            <Box italic>No patient strapped to the chair</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

