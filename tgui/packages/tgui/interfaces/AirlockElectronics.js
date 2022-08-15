import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Section, Flex, Tabs, Grid } from '../components';
import { Window } from '../layouts';

export const AirlockElectronics = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    oneAccess,
    unres_direction,
  } = data;
  const regions = data.regions || [];
  const accesses = data.accesses || [];
  return (
    <Window
      width={420}
      height={485}>
      <Window.Content>
        <Section title="Main">
          <LabeledList>
            <LabeledList.Item
              label="Access Required">
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                content={oneAccess ? 'One' : 'All'}
                onClick={() => act('one_access')} />
            </LabeledList.Item>
            <LabeledList.Item
              label="Unrestricted Access">
              <Button
                icon={unres_direction & 1 ? 'check-square-o' : 'square-o'}
                content="North"
                selected={unres_direction & 1}
                onClick={() => act('direc_set', {
                  unres_direction: '1',
                })} />
              <Button
                icon={unres_direction & 2 ? 'check-square-o' : 'square-o'}
                content="South"
                selected={unres_direction & 2}
                onClick={() => act('direc_set', {
                  unres_direction: '2',
                })} />
              <Button
                icon={unres_direction & 4 ? 'check-square-o' : 'square-o'}
                content="East"
                selected={unres_direction & 4}
                onClick={() => act('direc_set', {
                  unres_direction: '4',
                })} />
              <Button
                icon={unres_direction & 8 ? 'check-square-o' : 'square-o'}
                content="West"
                selected={unres_direction & 8}
                onClick={() => act('direc_set', {
                  unres_direction: '8',
                })} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <AirlockAccessList
          regions={regions}
          selectedList={accesses}
          accessMod={ref => act('set', {
            access: ref,
          })}
          denyAll={() => act('clear_all')}
          grantDep={ref => act('grant_region', {
            region: ref,
          })}
          denyDep={ref => act('deny_region', {
            region: ref,
          })} />
      </Window.Content>
    </Window>
  );
};

const diffMap = {
  0: {
    icon: 'times-circle',
    color: 'bad',
  },
  1: {
    icon: 'stop-circle',
    color: null,
  },
  2: {
    icon: 'check-circle',
    color: 'good',
  },
};

export const AirlockAccessList = (props, context) => {
  const {
    regions = [],
    selectedList = [],
    accessMod,
    denyAll,
    grantDep,
    denyDep,
  } = props;
  const [
    selectedRegion,
    setSelectedRegion,
  ] = useLocalState(context, 'region', Object.keys(regions)[0]);

  return (
    <Section
      title="Access"
      buttons={(
        <Button
          icon="undo"
          content="Deny All"
          color="bad"
          onClick={() => denyAll()} />
      )}>
      <Flex>
        <Flex.Item>
          <Tabs vertical>
            {Object.keys(regions).map(region => {
              const entries = regions[region] || [];
              return (
                <Tabs.Tab
                  key={region}
                  altSelection
                  selected={region === selectedRegion}
                  onClick={() => setSelectedRegion(region)}>
                  {region}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} ml={1.5}>
          <Grid>
            <Grid.Column mr={0}>
              <Button
                fluid
                icon="check"
                content="Grant Region"
                color="good"
                onClick={() => grantDep(selectedRegion)} />
            </Grid.Column>
            <Grid.Column ml={0}>
              <Button
                fluid
                icon="times"
                content="Deny Region"
                color="bad"
                onClick={() => denyDep(selectedRegion)} />
            </Grid.Column>
          </Grid>
          {regions[selectedRegion].map(entry => (
            <Button.Checkbox
              fluid
              key={entry.name}
              content={entry.name}
              checked={selectedList.includes(entry.id)}
              onClick={() => accessMod(entry.id)} />
          ))}
        </Flex.Item>
      </Flex>
    </Section>
  );
};
