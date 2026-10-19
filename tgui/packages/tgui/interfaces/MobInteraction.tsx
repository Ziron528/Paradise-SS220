import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  isTargetSelf: boolean;
  user: string;
  target: string | null;
  selfAttributes: string[];
  theirAttributes: string[] | null;
  max_distance: number | null;
  target_is_blacklisted: boolean | null;
  auto_interaction_pace: number;
  is_auto_target_self: boolean;
  auto_interaction_target: string | null;
  currently_active_interaction: string | null;
  hidden_interactions_keys: string[];
  interactions: {
    key: string;
    desc: string;
    type: number;
    maxDistance: number;
    interactionFlags: number;
    required_from_user: number;
    required_from_target: number;
  }[];
  interaction_speeds: number[];
};

export const MobInteraction = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    isTargetSelf,
    user,
    target,
    selfAttributes,
    theirAttributes,
    max_distance,
    target_is_blacklisted,
    auto_interaction_pace,
    is_auto_target_self,
    auto_interaction_target,
    currently_active_interaction,
    hidden_interactions_keys,
    interactions,
    interaction_speeds,
  } = data;
  const isHidden = (key: string) => hidden_interactions_keys.includes(key);
  return (
    <Window width={640} height={560}>
      <Window.Content scrollable>
        <Section title="Цель">
          {target ? `Взаимодействие: ${user} → ${target}` + (isTargetSelf ? ' (на себя)' : '') : 'Цель не выбрана.'}
          {max_distance !== null && ` · Дистанция: ${max_distance}`}
          {target_is_blacklisted && ' · ЦЕЛЬ В БЛЭКЛИСТЕ'}
        </Section>
        <Section title="Атрибуты">
          <Box bold mb="2px">
            Ты:
          </Box>
          <Box>{selfAttributes.join(' ')}</Box>
          {theirAttributes && !isTargetSelf && (
            <>
              <Box bold mt="6px" mb="2px">
                Цель:
              </Box>
              <Box>{theirAttributes.join(' ')}</Box>
            </>
          )}
        </Section>
        <Section title="Действия">
          {interactions.map((i) => (
            <Stack key={i.key} mb="4px">
              <Stack.Item grow>
                <Button
                  fluid
                  content={i.desc}
                  disabled={!!target_is_blacklisted || (max_distance ?? 99) > i.maxDistance}
                  onClick={() => act('interact', { interaction: i.key })}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={is_auto_target_self && currently_active_interaction === i.key ? 'stop' : 'play'}
                  tooltip="Авто-интеракция"
                  onClick={() => act('toggle_auto_interaction', { interaction: i.key })}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon={isHidden(i.key) ? 'eye-slash' : 'eye'}
                  tooltip="Скрыть/показать"
                  onClick={() => act('toggle_hidden_interaction', { interaction: i.key })}
                />
              </Stack.Item>
            </Stack>
          ))}
        </Section>
        <Section title="Скорость авто-интеракции">
          {interaction_speeds.map((s) => (
            <Button
              key={s}
              selected={s === auto_interaction_pace}
              content={`${s}с`}
              onClick={() => act('interaction_pace', { speed: s })}
            />
          ))}
          {auto_interaction_target && (
            <Box mt="4px">
              Авто: {auto_interaction_target}{' '}
              <Button
                compact
                icon="stop"
                content="Стоп"
                onClick={() => act('toggle_auto_interaction', { interaction: currently_active_interaction })}
              />
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
