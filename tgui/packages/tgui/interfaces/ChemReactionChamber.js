import { map } from 'common/collections';
import { toFixed } from 'common/math';
import { classes } from 'common/react';

import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Input, LabeledList, NumberInput, Section, Stack } from '../components';
import { Window } from '../layouts';

export const ChemReactionChamber = (props) => {
  const { act, data } = useBackend();
  const [
    reagentName,
    setReagentName,
  ] = useLocalState('reagentName', '');
  const [
    reagentQuantity,
    setReagentQuantity,
  ] = useLocalState('reagentQuantity', 1);
  const reagents = data.reagents || [];
  return (
    <Window
      width={250}
      height={325}>
      <Window.Content scrollable>
        <Section
          title="Temperature"
          buttons={
            <NumberInput
              width="65px"
              unit="K"
              step={10}
              stepPixelSize={3}
              value={data.target_temperature}
              minValue={0}
              maxValue={1000}
              onDrag={(value) =>
                act('temperature', {
                  target: value,
                })}
            />
          }>
          <Stack fill>
            <Stack.Item textColor="label">
              Current:
            </Stack.Item>
            <Stack.Item grow>
              <AnimatedNumber
                value={data.temperature}
                format={(value) => toFixed(value) + ' K'}
              />
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="Reagents"
          buttons={(
            <Box
              inline
              bold
              color={data.emptying ? "bad" : "good"}>
              {data.emptying ? "Emptying" : "Filling"}
            </Box>
          )}>
          <LabeledList>
            <tr className="LabledList__row">
              <td
                colSpan="2"
                className="LabeledList__cell">
                <Input
                  fluid
                  value=""
                  placeholder="Reagent Name"
                  onInput={(e, value) => setReagentName(value)} />
              </td>
              <td
                className={classes([
                  "LabeledList__buttons",
                  "LabeledList__cell",
                ])}>
                <NumberInput
                  value={reagentQuantity}
                  minValue={1}
                  maxValue={100}
                  step={1}
                  stepPixelSize={3}
                  width="39px"
                  onDrag={(value) => setReagentQuantity(value)} />
                <Box inline mr={1} />
                <Button
                  icon="plus"
                  onClick={() => act('add', {
                    chem: reagentName,
                    amount: reagentQuantity,
                  })} />
              </td>
            </tr>
            {map(reagents, (reagent) => (
              <LabeledList.Item
                key={reagent.name}
                label={reagent.name}
                buttons={(
                  <Button
                    icon="minus"
                    color="bad"
                    onClick={() => act('remove', {
                      chem: reagent.name,
                    })} />
                )}>
                {reagent.amount}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
